#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "initializing (++)Ethereum Classic installation"
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
# Setup (++)Ethereum Classic
####################
time sudo apt-get install -y git
time sudo apt-get update
time sudo git clone https://github.com/ethereumproject/cpp-ethereum.git
time cd cpp-ethereum
time sudo ./scripts/install_deps.sh
time sudo mkdir build
time cd build
time sudo cmake ..
time sudo make



# Fetch Genesis and Private Key
cd $HOMEDIR

date
echo "completed (++)Ethereum Classic install $$"
