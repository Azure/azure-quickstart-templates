#!/bin/bash

if [ $# -eq 0 ];
	then GETH_CFG="/home/gethuser/geth.cfg" #Assume cfg is in homedir
else
	GETH_CFG=$1
fi

# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config ($GETH_CFG) file not found. Exiting"; exit 1; fi
. $GETH_CFG

geth attach ipc:$GETH_HOME/geth.ipc
