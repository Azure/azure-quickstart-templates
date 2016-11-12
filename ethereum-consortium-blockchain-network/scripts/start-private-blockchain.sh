#!/bin/bash

set -x;

#############
# Parameters
#############
# Validate that all arguments are supplied
#if [ $# -ne 1 ]; then echo "Incomplete parameters supplied. usage: \"$0 <config file path>\""; exit 1; fi

GETH_CFG=$1;

# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config file not found. Exiting"; exit 1; fi
. $GETH_CFG;

# Get IP address for geth RPC binding
IPADDR=`ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`;

# Only mine on mining nodes
if [ $NODE_TYPE -ne 2 ]; then
	MINE_OPTIONS="--mine --minerthreads $MINER_THREADS";
else
	FAST_SYNC="--fast";
fi

VERBOSITY=4;

nohup geth --datadir $GETH_HOME -verbosity $VERBOSITY --bootnodes $BOOTNODE_URLS --maxpeers $MAX_PEERS --nat none --networkid $NETWORK_ID --identity $IDENTITY $MINE_OPTIONS $FAST_SYNC --rpc --rpcaddr "$IPADDR" --rpccorsdomain "*" >> $GETH_LOG_FILE_PATH 2>&1 &
echo "===== Started geth =====";

if [ $NODE_TYPE -eq 2 ]; then
	cd $ETHERADMIN_HOME;
	nohup nodejs app.js $GETH_HOME/geth.ipc $PREFUND_ADDRESS $PASSWD $MN_NODE_PREFIX $NUM_MN_NODES $TX_NODE_PREFIX $NUM_TX_NODES >> etheradmin.log &
	echo "===== Started admin webserver =====";
fi

echo "===== Completed executing start-private-blockchain.sh =====";
