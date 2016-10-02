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
# Setup Geth classic
####################
time sudo apt-get install -y git
time sudo apt-get update
time sudo git clone https://github.com/ethereumproject/go-ethereum.git
time sudo apt-get install -y build-essential libgmp3-dev golang software-properties-common
time cd go-ethereum
time sudo make geth

date
echo "completed geth Classic Chain install $$"
