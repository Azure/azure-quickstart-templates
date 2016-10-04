#!/bin/bash

if [ $# -eq 0 ];
        then GETH_CFG="/home/gethuser/geth.cfg" #Assume cfg is in homedir
else
        GETH_CFG=$1
fi
# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config file not found. Exiting"; exit 1; fi
. $GETH_CFG


if [ $NODE_TYPE -eq 0 ]; then
	sh configure-geth.sh gethuser Berlin1 $NETWORK_ID $MAX_PEERS $NODE_TYPE $NODE_KEY $STATIC_NODE_URL;
else
	sh configure-geth.sh gethuser Berlin1 $NETWORK_ID $MAX_PEERS $NODE_TYPE $BOOT_NODE_URL;
fi
