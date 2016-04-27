#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "starting augur installation"
date

#############
# Parameters
#############

AZUREUSER=$1
VMNAME=`hostname`
HOMEDIR="/home/$AZUREUSER"
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

cd $HOMEDIR

#####################
# install tools
#####################
#time curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
#time sudo apt-get install -y nodejs
#time sudo apt-get install -y build-essential

#time sudo apt-get -y install git
#time sudo apt-get -y install libssl-dev

####################
# Intsall Geth
####################
#time sudo apt-get install -y software-properties-common
#time sudo add-apt-repository -y ppa:ethereum/ethereum
#time sudo add-apt-repository -y ppa:ethereum/ethereum-dev
#time sudo apt-get update
#time sudo apt-get install -y ethereum

####################
# Install Serpent
####################
#time sudo apt-get install -y python-dev
#time sudo apt-get install -y python-pip
#time sudo apt-get install -y build-essential automake pkg-config libtool libffi-dev libgmp-dev -y
#time sudo pip install ethereum-serpent
#time sudo pip install ethereum
#time sudo pip install requests --upgrade
#time sudo pip install pyethapp

#time sudo apt-get update

###############################
# Fetch Genesis and Private Key
###############################
#sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/genesis.json
#sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/priv_genesis.key
#sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/mining_toggle.js
#sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/geth.conf
#sed -i "s/auguruser/$AZUREUSER/g" geth.conf

####################
# Setup Geth
####################
#sudo -i -u $AZUREUSER geth init genesis.json 
#sudo -u $AZUREUSER echo "password" > pw.txt
#sudo -i -u $AZUREUSER geth --password pw.txt account import priv_genesis.key

#Pregen DAG so miniing can start immediately
#sudo -u $AZUREUSER mkdir .ethash
#sudo -i -u $AZUREUSER geth makedag 0 .ethash

#make geth a service, turn on.
#cp geth.conf /etc/init/
#start geth 

####################
#Install Augur Contracts
####################
#sudo -u $AZUREUSER git clone https://github.com/AugurProject/augur-core.git
#cd  augur-core
#python load_contracts.py
#cd ..

####################
#Install Augur Front End
####################
#sudo -u $AZUREUSER git clone https://github.com/AugurProject/augur.git
sudo -i -u $AZUREUSER  bash -c "cd augur; npm install $HOMEDIR/augur"
sudo -i -u $AZUREUSER bash -c "cd augur; npm run build"

#allow nodejs to run on port 80 w/o sudo
setcap 'cap_net_bind_service=+ep' /usr/bin/nodejs

export PORT=80
#npm start


date
echo "completed augur install $$"