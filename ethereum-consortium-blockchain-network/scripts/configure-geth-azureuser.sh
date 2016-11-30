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
NODE_TYPE=$7;       # (0=Transaction node; 1=Mining node )
GETH_IPC_PORT=$8;
NUM_BOOT_NODES=$9;
NUM_MN_NODES=${10};
MN_NODE_PREFIX=${11};
MN_NODE_SEQNUM=${12};   #Only supplied for NODE_TYPE=1
NUM_TX_NODES=${12};     #Only supplied for NODE_TYPE=0
TX_NODE_PREFIX=${13};   #Only supplied for NODE_TYPE=0
ADMIN_SITE_PORT=${14};  #Only supplied for NODE_TYPE=0

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
sudo add-apt-repository -y ppa:ethereum/ethereum || exit 1;
sudo apt-get -y update || exit 1;
# To avoid intermittent issues with package DB staying locked when next apt-get runs
sleep 5;

##################
# Install packages
##################
sudo apt-get -y install npm=3.5.2-0ubuntu4 git=1:2.7.4-0ubuntu1 software-properties-common=0.96.20.4 ethereum || exit 1;
sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100 || exit 1;

#############
# Build node keys and node IDs
#############
declare -a NODE_KEYS
declare -a NODE_IDS
for i in `seq 0 $(($NUM_BOOT_NODES - 1))`; do
	BOOT_NODE_HOSTNAME=$MN_NODE_PREFIX$i;
	NODE_KEYS[$i]=`echo $BOOT_NODE_HOSTNAME | sha256sum | cut -d ' ' -f 1`;
	setsid geth -nodekeyhex ${NODE_KEYS[$i]} > $HOMEDIR/tempbootnodeoutput 2>&1 &
	while sleep 10; do
		if [ -s $HOMEDIR/tempbootnodeoutput ]; then
			killall geth;
			NODE_IDS[$i]=`grep -Po '(?<=\/\/).*(?=@)' $HOMEDIR/tempbootnodeoutput`;
			rm $HOMEDIR/tempbootnodeoutput;
			if [ $? -ne 0 ]; then
				exit 1;
			fi
			break;
		fi
	done
done

##################################
# Check for empty node keys or IDs
##################################
for nodekey in "${NODE_KEYS[@]}"; do
	if [ -z $nodekey ]; then
		exit 1;
	fi
done
for nodeid in "${NODE_IDS[@]}"; do
	if [ -z $nodeid ]; then
		exit 1;
	fi
done

##############################################
# Setup Genesis file and pre-allocated account
##############################################
PASSWD_FILE="$GETH_HOME/passwd.info";
printf %s $PASSWD > $PASSWD_FILE;

PRIV_KEY=`echo "$PASSPHRASE" | sha256sum | sed s/-// | sed "s/ //"`;
printf "%s" $PRIV_KEY > $HOMEDIR/priv_genesis.key;
PREFUND_ADDRESS=`geth --datadir $GETH_HOME --password $PASSWD_FILE account import $HOMEDIR/priv_genesis.key | grep -oP '\{\K[^}]+'`;
rm $HOMEDIR/priv_genesis.key;
rm $PASSWD_FILE;

cd $HOMEDIR
wget -N ${ARTIFACTS_URL_PREFIX}/scripts/start-private-blockchain.sh || exit 1;
wget -N ${ARTIFACTS_URL_PREFIX}/genesis-template.json || exit 1;
# Place our calculated difficulty into genesis file
sed s/#DIFFICULTY/$DIFFICULTY/ $HOMEDIR/genesis-template.json > $HOMEDIR/genesis-intermediate.json;
sed s/#PREFUND_ADDRESS/$PREFUND_ADDRESS/ $HOMEDIR/genesis-intermediate.json > $HOMEDIR/genesis.json;

####################
# Initialize geth for private network
####################
if [ $NODE_TYPE -eq 1 ] && [ $MN_NODE_SEQNUM -lt $NUM_BOOT_NODES ]; then #Boot node logic
	printf %s ${NODE_KEYS[$MN_NODE_SEQNUM]} > $NODEKEY_FILE_PATH;
fi

#################
# Initialize geth
#################
geth --datadir $GETH_HOME -verbosity 6 init $GENESIS_FILE_PATH >> $GETH_LOG_FILE_PATH 2>&1;
if [ $? -ne 0 ]; then
	exit 1;
fi
echo "===== Completed geth initialization =====";

#####################
# Setup admin website
#####################
if [ $NODE_TYPE -eq 0 ]; then # TX nodes only
  mkdir -p $ETHERADMIN_HOME/views/layouts;
  cd $ETHERADMIN_HOME/views/layouts;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/main.handlebars || exit 1;
  cd $ETHERADMIN_HOME/views;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/etheradmin.handlebars || exit 1;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/etherstartup.handlebars || exit 1;
  cd $ETHERADMIN_HOME;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/package.json || exit 1;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/npm-shrinkwrap.json || exit 1;
  npm install || exit 1;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/app.js || exit 1;
  mkdir $ETHERADMIN_HOME/public;
  cd $ETHERADMIN_HOME/public;
  wget -N ${ARTIFACTS_URL_PREFIX}/scripts/etheradmin/skeleton.css || exit 1;
fi

#########################
# Generate boot node URLs
####################
BOOTNODE_URLS="";
for i in `seq 0 $(($NUM_BOOT_NODES - 1))`; do
	BOOTNODE_URLS="${BOOTNODE_URLS}enode://${NODE_IDS[$i]}@#${MN_NODE_PREFIX}${i}#:${GETH_IPC_PORT}";
  if [ $i -lt $(($NUM_BOOT_NODES - 1)) ]; then
  	BOOTNODE_URLS="${BOOTNODE_URLS},";
  fi
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
printf "%s\n" "MN_NODE_PREFIX=$MN_NODE_PREFIX" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "NUM_BOOT_NODES=$NUM_BOOT_NODES" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "MINER_THREADS=$MINER_THREADS" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GETH_HOME=$GETH_HOME" >> $GETH_CFG_FILE_PATH;
printf "%s\n" "GETH_LOG_FILE_PATH=$GETH_LOG_FILE_PATH" >> $GETH_CFG_FILE_PATH;

if [ $NODE_TYPE -eq 0 ]; then #TX node
  printf "%s\n" "ETHERADMIN_HOME=$ETHERADMIN_HOME" >> $GETH_CFG_FILE_PATH;
  printf "%s\n" "PREFUND_ADDRESS=$PREFUND_ADDRESS" >> $GETH_CFG_FILE_PATH;
  printf "%s\n" "NUM_MN_NODES=$NUM_MN_NODES" >> $GETH_CFG_FILE_PATH;
  printf "%s\n" "TX_NODE_PREFIX=$TX_NODE_PREFIX" >> $GETH_CFG_FILE_PATH;
  printf "%s\n" "NUM_TX_NODES=$NUM_TX_NODES" >> $GETH_CFG_FILE_PATH;
  printf "%s\n" "ADMIN_SITE_PORT=$ADMIN_SITE_PORT" >> $GETH_CFG_FILE_PATH;
fi

##########################################
# Setup rc.local for service start on boot
##########################################
echo "sudo -u $AZUREUSER /bin/bash $HOMEDIR/start-private-blockchain.sh $GETH_CFG_FILE_PATH $PASSWD" | sudo tee /etc/rc.local 2>&1 1>/dev/null
if [ $? -ne 0 ]; then
	exit 1;
fi

############
# Start geth
############
/bin/bash $HOMEDIR/start-private-blockchain.sh $GETH_CFG_FILE_PATH $PASSWD || exit 1;
echo "Commands succeeded. Exiting";
exit 0;