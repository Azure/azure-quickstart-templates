#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "initializing geth Classic Chain installation"
date
ps axjf

#############
# Parameters
#############

AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

#####################
# setup the Azure CLI
#####################
time sudo npm install azure-cli -g
time sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

####################
# Setup Geth classic - using launchpad ppa
####################
time sudo add-apt-repository ppa:ethereum-classic/etc-geth
time sudo apt-get update
time apt-get install -y ethereum-classic-unstable

date
echo "completed geth Classic Chain install $$"
