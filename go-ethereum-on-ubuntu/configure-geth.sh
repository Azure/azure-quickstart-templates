#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "initializing geth installation"
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
# Setup Geth
####################
time sudo apt-get -y git
time sudo apt-get install -y software-properties-common
time sudo add-apt-repository -y ppa:ethereum/ethereum
time sudo apt-get update
time sudo apt-get install -y ethereum

####################
# Install sol compiler
####################
time sudo add-apt-repository ppa:ethereum/ethereum -y
time sudo apt-get update
time sudo apt-get install solc -y

# Fetch Genesis and Private Key
cd $HOMEDIR
wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/go-ethereum-on-ubuntu/genesis.json
wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/go-ethereum-on-ubuntu/priv_genesis.key
wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/go-ethereum-on-ubuntu/start-private-blockchain.sh
wget https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/go-ethereum-on-ubuntu/GuestBook.sol

date
geth init genesis.json
echo "completed geth install $$"
