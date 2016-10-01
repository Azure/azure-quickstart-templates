#!/bin/bash

echo "===== Initializing geth installation =====";
date;

############
# Parameters
############
# Validate that all arguments are supplied
if [ $# -lt 10 ]; then echo "Insufficient parameters supplied. Exiting"; exit 1; fi

AZUREUSER=$1;
PASSWD=$2;
PASSPHRASE=$3;
ARTIFACTS_URL_PREFIX=$4;
NETWORK_ID=$5;
MAX_PEERS=$6;
NODE_TYPE=$7; 		# (0=Transaction node; 1=Mining node )
GETH_IPC_PORT=$8;
NUM_BOOT_NODES=$9;
NUM_MN_NODES=$10;
MN_NODE_PREFIX=$11;
MN_NODE_SEQNUM=$12; # Only supplied for NODE_TYPE=1
NUM_TX_NODES=$12;	# Only supplied for NODE_TYPE=0
TX_NODE_PREFIX=$13;	# Only supplied for NODE_TYPE=0

###########
# Constants
###########
NODE_KEY1="42fa516481d64692431fda09114912566a4e9b36bb5aae2ad52ef1bbbb212c59";
NODE_KEY2="40591f6282ace5b586e76abfba5641be515add41d39df7f1c86931ad046e9b60";
NODE_KEY3="66de5a329cbe4b45cf4e305c8920f99a683b70b56921166c5a3357c3b2da00e2";
NODE_KEY4="11b59a95b52ed643a6bfc9b738765fc53e030d7b9c40f524ab8e9b56a6d1953e";
NODE_KEY5="361fbc87dd053f50babc752c56bc1bd80f3a74338d970232800f8f52d82e5374";
NODE_ID1="399fedb4bbedef3fc9077f6a8bd2b96112723c668e7b3072a802f15ca17622e799439470814f9b0bded21edd641eb4f727cd09836c09f38c6688e65b49edddcf";
NODE_ID2="44ecec4c1c96cdd3ac77a04e9839278fc2db0979559244c38c2fe9494896e7eb574a2f040e401be09ad8ead5adee1915d2ec640016e253aa736a5958c10c476b";
NODE_ID3="26661f1986f3b9c8bc28fd7aa8abcc5b6967421ccf3069f87d282d2aac040bf3c8b8e07784baf4e7b9b8b07edecf95b1da76e65f7db6612841011dffe154a142";
NODE_ID4="9409170771c71385e67db347013db8b2820b3610fc00c9d777a66178a6554e7098ee16024148b6063b743c345d591f76962f84d5fd441aefaaaddc9a1d83fbda";
NODE_ID5="f7460d34915d54aa716d330f64638e446fca843f1c84fbbc7f50b7f6fd67da375658c97b2829274893d21daa4ee5142773be74f57999985f3d83817e497295cd";
MINER_THREADS=1;
# Difficulty constant represents ~15 sec. block generation for one node
DIFFICULTY_CONSTANT="0x3333";

HOMEDIR="/home/$AZUREUSER";
VMNAME=`hostname`;
GETH_HOME="$HOMEDIR/.ethereum";
mkdir -p $GETH_HOME;
ETHERADMIN_HOME="$HOMEDIR/etheradmin";
GETH_LOG_FILE_PATH="$HOMEDIR/geth.log";
GENESIS_FILE_PATH="$HOMEDIR/genesis.json";
GETH_CFG_FILE_PATH="$HOMEDIR/geth.cfg";
NODEKEY_FILE_PATH="$GETH_HOME/nodekey";

##################
# Scale difficulty
##################
# Target difficulty scales with number of miners
DIFFICULTY=`printf "0x%X" $(($DIFFICULTY_CONSTANT * $NUM_MN_NODES))`;


################
# Update modules
################
sudo apt-get -y update;

##############
# setup Nodejs
##############
sudo apt-get -y install npm;
sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100;

##############
# Setup Geth #
##############
sudo apt-get -y install git;
sudo apt-get -y install software-properties-common;
#sudo add-apt-repository -y ppa:ethereum/ethereum-dev # We want the stable version
sudo add-apt-repository -y ppa:ethereum/ethereum;
sudo apt-get -y update;
sudo apt-get install -y ethereum;

##############################################
# Setup Genesis file and pre-allocated account
##############################################
PASSWD_FILE="$GETH_HOME/passwd.info";
printf %s $PASSWD > $PASSWD_FILE;

PRIV_KEY=`echo "$PASSPHRASE" | sha256sum | sed s/-// | sed "s/ //"`;
printf "%s" $PRIV_KEY > $HOMEDIR/priv_genesis.key;
PREFUND_ADDRESS=`geth --datadir $GETH_HOME --password $PASSWD_FILE account import $HOMEDIR/priv_genesis.key | grep -oP '\{\K[^}]+'`;
rm $HOMEDIR/priv_genesis.key;

cd $HOMEDIR
wget -N ${ARTIFACTS_URL_PREFIX}/scripts/start-private-blockchain.sh;
wget -N ${ARTIFACTS_URL_PREFIX}/genesis-template.json;
# Place our calculated difficulty into genesis file
sed s/#DIFFICULTY/$DIFFICULTY/ $HOMEDIR/genesis-template.json > $HOMEDIR/genesis-intermediate.json;
sed s/#PREFUND_ADDRESS/$PREFUND_ADDRESS/ $HOMEDIR/genesis-intermediate.json > $HOMEDIR/genesis.json;

#####################################
# Generate node key (boot nodes only)
#####################################
if [ $NODE_TYPE -eq 1 ] && [ $MN_NODE_SEQNUM -lt $NUM_BOOT_NODES ]; then #Boot nodes only
	# Iterating since this version of bash doesn't support arrays
	COUNTER=0;
	for NODE_KEY in $NODE_KEY1 $NODE_KEY2 $NODE_KEY3 $NODE_KEY4 $NODE_KEY5; do
		if [ $COUNTER -eq $MN_NODE_SEQNUM ]; then break; fi
  		COUNTER=$(($COUNTER + 1));
	done
	printf %s $NODE_KEY > $NODEKEY_FILE_PATH;
fi

#################
# Initialize geth
#################
geth --datadir $GETH_HOME -verbosity 6 init $GENESIS_FILE_PATH >> $GETH_LOG_FILE_PATH 2>&1;
echo "===== Completed geth initialization =====";

#####################
# Setup admin website
#####################
if [ $NODE_TYPE -eq 0 ]; then # TX nodes only
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

#########################
# Generate boot node URLs
#########################
COUNTER=0;
BOOTNODE_URLS="";
for NODE_ID in $NODE_ID1 $NODE_ID2 $NODE_ID3 $NODE_ID4 $NODE_ID5; do
	if [ $COUNTER -ge $NUM_BOOT_NODES ]; then break; fi
  	IP_ADDR=`nslookup ${MN_NODE_PREFIX}${COUNTER}| egrep "Address: [0-9]"| cut -d' ' -f2`;
	BOOTNODE_URLS="${BOOTNODE_URLS}enode://${NODE_ID}@${IP_ADDR}:${GETH_IPC_PORT}";
    if [ $COUNTER -lt $(($NUM_BOOT_NODES - 1)) ]; then
    	BOOTNODE_URLS="${BOOTNODE_URLS},";
  	fi
    COUNTER=$(($COUNTER + 1));
done

##################
# Create conf file
##################
printf "%s\n" "HOMEDIR=$HOMEDIR" > $GETH_CFG_FILE_PATH;
printf "%s\n" "IDENTITY=$VMNAME" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "NETWORK_ID=$NETWORK_ID" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "MAX_PEERS=$MAX_PEERS" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "NODE_TYPE=$NODE_TYPE" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "BOOTNODE_URLS=$BOOTNODE_URLS" >> $GETH_CFG_FILE_PATH;
if [ $NODE_TYPE -eq 0 ]; then #TX node
	printf "%s\n" "ETHERADMIN_HOME=$ETHERADMIN_HOME" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "PREFUND_ADDRESS=$PREFUND_ADDRESS" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "MN_NODE_PREFIX=$MN_NODE_PREFIX" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "NUM_MN_NODES=$NUM_MN_NODES" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "TX_NODE_PREFIX=$TX_NODE_PREFIX" >> $GETH_CFG_FILE_PATH;
	printf "%s\n" "NUM_TX_NODES=$NUM_TX_NODES" >> $GETH_CFG_FILE_PATH;
fi
printf "%s\n" "MINER_THREADS=$MINER_THREADS" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GETH_HOME=$GETH_HOME" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GETH_LOG_FILE_PATH=$GETH_LOG_FILE_PATH" >> $GETH_CFG_FILE_PATH;

############
# Start geth
############
sh $HOMEDIR/start-private-blockchain.sh $GETH_CFG_FILE_PATH $PASSWD
echo "===== Started geth node =====";