#!/bin/bash

# If there is a problem initializing, check the log file (root permission required)
# /var/log/azure/Microsoft.Azure.Extensions/<version>/handler.log
# /var/lib/azure/customscript/download/<n>/(stdout|stderr)

# Debug
set -x

echo "Initializing MultiChain installation"
date
#ps axjf

#############
# Parameters
#############

AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
CHAINNAME="chain1"
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"
echo "chain name: $CHAINNAME"

# This is run as root
cd $(mktemp -d)
wget --no-verbose http://www.multichain.com/download/multichain-latest.tar.gz
tar xvf multichain-latest.tar.gz
cp multichain-1.0-alpha*/multichain* /usr/local/bin/

# As regular user
su -l $AZUREUSER -c "multichain-util create ${CHAINNAME}"
su -l $AZUREUSER -c "sed -i \"s/^default-network-port =.*/default-network-port = 8333/\" $HOMEDIR/.multichain/${CHAINNAME}/params.dat"
su -l $AZUREUSER -c "sed -i \"s/^default-rpc-port =.*/default-rpc-port = 8332/\" $HOMEDIR/.multichain/${CHAINNAME}/params.dat"
su -l $AZUREUSER -c "multichaind ${CHAINNAME} -daemon"
sleep 5
su -l $AZUREUSER -c "multichain-cli ${CHAINNAME} getinfo"


date
echo "Completed MultiChain install $$"

