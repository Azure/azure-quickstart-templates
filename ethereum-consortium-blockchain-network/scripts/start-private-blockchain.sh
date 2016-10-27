#!/bin/bash

#############
# Parameters
#############
if [ $# -lt 2 ]; then echo "Incomplete parameters supplied. usage: \"$0 <config file path> <ethereum account passwd>\""; exit 1; fi
GETH_CFG=$1;
PASSWD=$2;

# Load config variables
if [ ! -e $GETH_CFG ]; then echo "Config file not found. Exiting"; exit 1; fi
. $GETH_CFG

# Ensure that at least one bootnode is up
# If not, wait 5 seconds then retry
FOUND_BOOTNODE=false
while sleep 5; do
	for i in `seq 0 $(($NUM_BOOT_NODES - 1))`; do
		if [ `hostname` = $MN_NODE_PREFIX$i ]; then
			continue
		fi

		LOOKUP=`nslookup $MN_NODE_PREFIX$i | grep "can't find"`
		if [ -z $LOOKUP ]; then
			FOUND_BOOTNODE=true
			break
		fi
	done

	if [ "$FOUND_BOOTNODE" = true ]; then
		break
	fi
done

# Replace hostnames in config file with IP addresses
BOOTNODE_URLS=`perl -pe 's/#(.*?)#/qx\/nslookup $1| egrep "Address: [0-9]"| cut -d" " -f2 | xargs echo -n\//ge' $GETH_CFG | grep BOOTNODE_URLS | cut -d'=' -f2`

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
  nohup nodejs app.js $ADMIN_SITE_PORT $GETH_HOME/geth.ipc $PREFUND_ADDRESS $PASSWD $MN_NODE_PREFIX $NUM_MN_NODES $TX_NODE_PREFIX $NUM_TX_NODES $NUM_BOOT_NODES >> $ETHERADMIN_LOG_FILE_PATH 2>&1 &
  if [ $? -ne 0 ]; then echo "Previous command failed. Exiting"; exit $?; fi
  echo "===== Started admin webserver =====";
fi
echo "===== Completed $0 =====";
