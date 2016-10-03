#!/bin/bash

#############
# Parameters
#############
if [ $# -lt 2 ]; then echo "Incomplete parameters supplied. usage: \"$0 <config file path> <ethereum account passwd>\""; exit 1; fi
GETH_CFG=$1;
PASSWD=$2;

# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config file not found. Exiting"; exit 1; fi
. $GETH_CFG;

ETHERADMIN_LOG_FILE_PATH="$HOMEDIR/etheradmin.log";

# Get IP address for geth RPC binding
IPADDR=`ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`;

# Only mine on mining nodes
if [ $NODE_TYPE -ne 0 ]; then
  MINE_OPTIONS="--mine --minerthreads $MINER_THREADS";
else
  FAST_SYNC="--fast";
fi

VERBOSITY=4;

echo "===== Starting geth node =====";
set -x;
nohup geth --datadir $GETH_HOME -verbosity $VERBOSITY --bootnodes $BOOTNODE_URLS --maxpeers $MAX_PEERS --nat none --networkid $NETWORK_ID --identity $IDENTITY $MINE_OPTIONS $FAST_SYNC --rpc --rpcaddr "$IPADDR" --rpccorsdomain "*" >> $GETH_LOG_FILE_PATH 2>&1 &
if [ $? -ne 0 ]; then echo "Previous command failed. Exiting"; exit $?; fi
set +x;
echo "===== Started geth node =====";

# Startup admin site on TX VMs
if [ $NODE_TYPE -eq 0 ]; then
  cd $ETHERADMIN_HOME;
  echo "===== Starting admin webserver =====";
  nohup nodejs app.js $GETH_HOME/geth.ipc $PREFUND_ADDRESS $PASSWD $MN_NODE_PREFIX $NUM_MN_NODES $TX_NODE_PREFIX $NUM_TX_NODES >> $ETHERADMIN_LOG_FILE_PATH 2>&1 &
  if [ $? -ne 0 ]; then echo "Previous command failed. Exiting"; exit $?; fi
  echo "===== Started admin webserver =====";
fi
echo "===== Completed $0 =====";