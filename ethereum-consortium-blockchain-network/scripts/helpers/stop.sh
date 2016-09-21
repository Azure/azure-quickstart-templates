#!/bin/bash

if [ $# -eq 0 ];
        then GETH_CFG="/home/gethuser/geth.cfg" #Assume cfg is in homedir
else
        GETH_CFG=$1
fi
# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config file not found. Exiting"; exit 1; fi
. $GETH_CFG

PID=`pgrep geth`
printf "%s\n" "Killing process with PID $PID";
if [ -n "$PID" ]; then
	kill $PID;
	printf "%s\n" "Killed process $PID";
else
	printf "%s\n" "No process found to kill";
fi

if [ -e $GETH_HOME ]; then
	rm -rf $GETH_HOME;
	printf "%s\n" "Removed $GETH_HOME";
fi

if [ -e $LOG_FILE_PATH ]; then
	rm $LOG_FILE_PATH;
	printf "%s\n" "Removed $LOG_FILE_PATH";
fi
