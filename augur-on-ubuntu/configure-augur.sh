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
time sudo add-apt-repository -y ppa:ethereum/ethereum-dev
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


geth init genesis.json
echo "password" > pw.txt  #TODO:prompt for separate pw, or just pass in one from auguruser?
geth --password pw.txt account import priv_genesis.key
 
#Pregen DAG so miniing can start immediately, no delay between when front end is useable
mkdir ~/.ethash
geth makedag 0 ~/.ethash

geth --maxpeers 0 --networkid 1101011 --rpc --rpccorsdomain "*" console


####################
#Install Augur Front End
####################

git clone https://github.com/AugurProject/augur.git
cd augur
npm install
grunt
npm start

date
echo "completed geth install $$"
