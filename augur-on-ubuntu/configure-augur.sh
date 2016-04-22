#!/bin/bash

# print commands and arguments as they are executed
#set -x

echo "initializing geth installation"
date

#############
# Parameters
#############

AZUREUSER=$1
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "vmname: $VMNAME"

#####################
# install tools
#####################
time sudo apt-get update && sudo apt-get install npm -y
sudo ln -s /usr/bin/nodejs /usr/bin/node
time sudo apt-get update && sudo apt-get install screen -y
time sudo apt-get -y install git
time sudo apt-get -y install libssl-dev

####################
# Intsall Geth
####################
time sudo apt-get install -y software-properties-common
time sudo add-apt-repository -y ppa:ethereum/ethereum
time sudo add-apt-repository -y ppa:ethereum/ethereum-dev
time sudo apt-get update
time sudo apt-get install -y ethereum

####################
# Install Serpent
####################
time sudo apt-get install -y python-dev
time sudo apt-get install -y python-pip
time sudo apt-get install -y build-essential automake pkg-config libtool libffi-dev libgmp-dev -y
time sudo pip install ethereum-serpent
time sudo pip install ethereum
time sudo pip install requests --upgrade
time sudo pip install pyethapp

time sudo apt-get update

###############################
# Fetch Genesis and Private Key
###############################
#cd $HOMEDIR
wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/genesis.json
wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/priv_genesis.key
wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/mining_toggle.js
wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/geth.conf

####################
# Setup Geth
####################
geth init genesis.json 
echo "password" > pw.txt  #TODO:prompt for separate pw in tempalte, or just pass in one from auguruser?
geth --password pw.txt account import priv_genesis.key

#Pregen DAG so miniing can start immediately
mkdir .ethash
geth makedag 0 .ethash

#make geth a service, turn on.
cp geth.conf /etc/init/
start geth 

####################
#Install Augur Contracts
####################
git clone https://github.com/AugurProject/augur-core.git
cd  augur-core
python load_contracts.py
cd ..

####################
#Install Augur Front End
####################
#git clone https://github.com/AugurProject/augur.git
#cd augur
#sudo npm install
#npm start




date
echo "completed augur install $$"