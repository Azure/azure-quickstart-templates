#!/bin/bash

if [ $# -eq 0 ];
	then GETH_CFG="/home/gethuser/geth.cfg" #Assume cfg is in homedir
else
	GETH_CFG=$1
fi

# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config ($GETH_CFG) file not found. Exiting"; exit 1; fi
. $GETH_CFG

ENODE=`geth --exec "admin.nodeInfo" attach ipc:$GETH_HOME/geth.ipc |grep "enode:"|sed -r 's:.*"([^"]+)".*:\1:'`
IP_ADDR=`ifconfig|grep "inet addr"|grep -v "127.0.0.1"|sed -r 's:[^0-9.]*([0-9.]+).*:\1:'`
SED_ARG="-r 's/\[::\]/${IP_ADDR}/'"
ENODE=`echo $ENODE|eval sed "$SED_ARG"`

printf "%s\n" "$ENODE"
