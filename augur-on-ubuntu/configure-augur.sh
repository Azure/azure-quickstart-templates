#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "starting augur installation"
date

#############
# Parameters
#############

AZUREUSER=$1
LOCATION=$2
VMNAME=`hostname`
HOMEDIR="/home/$AZUREUSER"
ETHEREUM_HOST_RPC="http://${VMNAME}.${LOCATION}.cloudapp.azure.com:8545"
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

cd $HOMEDIR

#####################
# install tools
#####################
time curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
time sudo apt-get install -y nodejs
time sudo apt-get install -y build-essential
time sudo apt-get -y install git
time sudo apt-get -y install libssl-dev
time curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
time sudo apt-get install -y nodejs

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
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/genesis.json
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/priv_genesis.key
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/mining_toggle.js
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/web/augur-on-ubuntu/geth.conf
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/web/augur-on-ubuntu/augur_ui.conf
sed -i "s/auguruser/$AZUREUSER/g" geth.conf
sed -i "s/auguruser/$AZUREUSER/g" augur_ui.conf

touch /var/log/geth.sys.log
touch /var/log/augur_ui.sys.log
chown $AZUREUSER /var/log/geth.sys.log
chown $AZUREUSER /var/log/augur_ui.sys.log

####################
# Setup Geth
####################
sudo -i -u $AZUREUSER geth init genesis.json 
sudo -u $AZUREUSER echo "password" > pw.txt
sudo -i -u $AZUREUSER geth --password pw.txt account import priv_genesis.key

#make geth a service, turn on.
cp geth.conf /etc/init/
start geth

#Pregen DAG so miniing can start immediately
sudo -u $AZUREUSER mkdir .ethash
sudo -i -u $AZUREUSER geth makedag 0 .ethash


####################
#Install Augur Contracts
####################
sudo -i -u $AZUREUSER git clone https://github.com/AugurProject/augur-core.git
cd  augur-core
python load_contracts.py
cd ..

####################
#Make a swap file (node can get hungry)
####################
fallocate -l 128MiB /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

####################
#Install Augur Front End
####################
sudo -i -u $AZUREUSER git clone https://github.com/AugurProject/augur.git
sudo -i -u $AZUREUSER  bash -c "cd augur; npm install"
sudo -i -u $AZUREUSER bash -c "cd augur; npm run build"

#allow nodejs to run on port 80 w/o sudo
setcap 'cap_net_bind_service=+ep' /usr/bin/nodejs

#Make augur_ui a service, turn on.
#cp augur_ui.conf /etc/init/
#start augur_ui 

date
echo "completed augur install $$"
