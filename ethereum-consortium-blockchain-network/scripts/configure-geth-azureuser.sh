#!/bin/bash

# print commands and arguments as they are executed
set -x;

echo "===== Initializing geth installation =====";
date;

#############
# Parameters
#############
# Validate that all arguments are supplied
if [ $# -lt 7 ]; then echo "Incomplete parameters supplied. Exiting"; exit 1; fi

AZUREUSER=$1;
PASSWD=$2;
PRIV_KEY=$3;
ARTIFACTS_URL_PREFIX=$4;
NETWORK_ID=$5;
MAX_PEERS=$6;
NODE_TYPE=$7; #(0=Mining node; 1=Mining boot node; 2=Transaction node )
BOOTNODE_URLS=$8;
NUM_MN_NODES=$9;
NODE_KEY=$10; #Only supplied for NODE_TYPE=1
MN_NODE_PREFIX=$10; 	#Only supplied for NODE_TYPE=2
NUM_TX_NODES=$11;	#Only supplied for NODE_TYPE=2
TX_NODE_PREFIX=$12;	#Only supplied for NODE_TYPE=2

MINER_THREADS=1;
# Difficulty constant represents ~15 sec. block generation for one node
DIFFICULTY_CONSTANT="0x3333";
# Target difficulty scales with number of miners
DIFFICULTY=`printf "0x%X" $(($DIFFICULTY_CONSTANT * $NUM_MN_NODES))`;

HOMEDIR="/home/$AZUREUSER";
VMNAME=`hostname`;
GETH_HOME="$HOMEDIR/.ethereum";
mkdir -p $GETH_HOME;
ETHERADMIN_HOME="$HOMEDIR/etheradmin";
GETH_LOG_FILE_PATH="$HOMEDIR/geth.log";
GENESIS_FILE_PATH="$HOMEDIR/genesis.json";
GETH_CFG_FILE_PATH="$HOMEDIR/geth.cfg";
NODEKEY_FILE_PATH="$GETH_HOME/nodekey";

#####################
# Update modules
#####################
sudo apt-get -y update;

#####################
# setup Nodejs
#####################
sudo apt-get -y install npm;
sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100;

####################
# Setup Geth
####################
sudo apt-get -y install git;
sudo apt-get -y install software-properties-common;
#sudo add-apt-repository -y ppa:ethereum/ethereum-dev # We want the stable version
sudo add-apt-repository -y ppa:ethereum/ethereum;
sudo apt-get -y update;
sudo apt-get install -y ethereum;

####################
# Setup Genesis file and pre-allocated account
####################
PASSWD_FILE="$GETH_HOME/passwd.info";
printf %s $PASSWD > $PASSWD_FILE;

printf "%s" $PRIV_KEY > $HOMEDIR/priv_genesis.key;
PREFUND_ADDRESS=`geth --datadir $GETH_HOME --password $PASSWD_FILE account import $HOMEDIR/priv_genesis.key | grep -oP '\{\K[^}]+'`;
rm $HOMEDIR/priv_genesis.key;

cd $HOMEDIR
wget -N ${ARTIFACTS_URL_PREFIX}/scripts/start-private-blockchain.sh;
wget -N ${ARTIFACTS_URL_PREFIX}/genesis-template.json;
# Place our calculated difficulty into genesis file
sed s/#DIFFICULTY/$DIFFICULTY/ $HOMEDIR/genesis-template.json > $HOMEDIR/genesis-intermediate.json;
sed s/#PREFUND_ADDRESS/$PREFUND_ADDRESS/ $HOMEDIR/genesis-intermediate.json > $HOMEDIR/genesis.json;
wget -N https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/go-ethereum-on-ubuntu/GuestBook.sol;

####################
# Initialize geth for private network
####################

if [ $NODE_TYPE -eq 0 ]; then #Boot node logic
	printf %s $NODE_KEY > $NODEKEY_FILE_PATH;
fi

geth --datadir $GETH_HOME -verbosity 6 init $GENESIS_FILE_PATH >> $GETH_LOG_FILE_PATH 2>&1;
echo "===== Completed geth initialization =====";

####################
# Setup admin website
####################
if [ $NODE_TYPE -eq 2 ]; then
	mkdir -p $ETHERADMIN_HOME/views/layouts;
	cd $ETHERADMIN_HOME/views/layouts;
	wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/main.handlebars;
	cd $ETHERADMIN_HOME/views;
	wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/etheradmin.handlebars;
	wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/etherstartup.handlebars;
	cd $ETHERADMIN_HOME;
	wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/package.json;
	npm install;
	wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/app.js;
	mkdir $ETHERADMIN_HOME/public;
	cd $ETHERADMIN_HOME/public;
	wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/skeleton.css;
fi

# Create conf file
printf "%s\n" "HOMEDIR=$HOMEDIR" > $GETH_CFG_FILE_PATH;
printf "%s\n" "IDENTITY=$VMNAME" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "NETWORK_ID=$NETWORK_ID" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "MAX_PEERS=$MAX_PEERS" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "NODE_TYPE=$NODE_TYPE" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "BOOTNODE_URLS=$BOOTNODE_URLS" >> $GETH_CFG_FILE_PATH;
if [ $NODE_TYPE -eq 0 ]; then #Boot node
	printf "%s\n" "NODE_KEY=$NODE_KEY" >> $GETH_CFG_FILE_PATH;
fi
if [ $NODE_TYPE -eq 2 ]; then #TX node
	printf "%s\n" "ETHERADMIN_HOME=$ETHERADMIN_HOME" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "PREFUND_ADDRESS=$PREFUND_ADDRESS" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "PASSWD=$PASSWD" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "MN_NODE_PREFIX=$MN_NODE_PREFIX" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "NUM_MN_NODES=$NUM_MN_NODES" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "TX_NODE_PREFIX=$TX_NODE_PREFIX" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "NUM_TX_NODES=$NUM_TX_NODES" >> $GETH_CFG_FILE_PATH;
fi
printf "%s\n" "MINER_THREADS=$MINER_THREADS" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GETH_HOME=$GETH_HOME" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GENESIS_FILE_PATH=$GENESIS_FILE_PATH" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GETH_LOG_FILE_PATH=$GETH_LOG_FILE_PATH" >> $GETH_CFG_FILE_PATH;

####################
# Start geth
####################
sh $HOMEDIR/start-private-blockchain.sh $GETH_CFG_FILE_PATH >> $GETH_LOG_FILE_PATH 2>&1 &
echo "===== Started geth node =====";
