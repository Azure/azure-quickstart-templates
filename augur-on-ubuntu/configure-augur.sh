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
ETHEREUM_HOST_WS="ws://${VMNAME}.${LOCATION}.cloudapp.azure.com:8546"

echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"
echo "HOST_RPC: $ETHEREUM_HOST_RPC"
echo "HOST_WS: $ETHEREUM_HOST_WS"

cd $HOMEDIR

#####################
# install tools
#####################
time sudo apt-get update
time sudo apt-get -y install build-essential automake pkg-config libtool libffi-dev libgmp-dev libssl-dev git
time curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
time sudo apt-get -y install nodejs

####################
# Intsall Geth
####################
time sudo apt-get -y install software-properties-common
time sudo add-apt-repository -y ppa:ethereum/ethereum
time sudo add-apt-repository -y ppa:ethereum/ethereum-dev
time sudo apt-get update
time sudo apt-get -y install ethereum

####################
# Install Serpent
####################
time sudo apt-get install -y python-dev
time sudo apt-get install -y python-pip
time sudo pip install requests --upgrade
git clone https://github.com/ethereum/serpent
cd serpent
git checkout develop
time make
time sudo make install
time sudo python setup.py install
cd ..
git clone https://github.com/ethereum/pyethereum
cd pyethereum
time sudo pip install -r requirements.txt
time sudo python setup.py install
cd ..
time sudo apt-get update

##################
# Install node.js
##################
time sudo npm install augur.js

###############################
# Fetch Genesis and Private Key
###############################
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/genesis.json
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/priv_genesis.key
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/mining_toggle.js
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/geth.conf
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/augur_ui.conf
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/init_contracts.js
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/env.json
sudo -u $AZUREUSER sed -i "s|azure_http_url|$ETHEREUM_HOST_RPC|g" env.json
sudo -u $AZUREUSER sed -i "s|azure_ws_url|$ETHEREUM_HOST_WS|g" env.json
sudo -u $AZUREUSER sed -i "s|auguruser|$AZUREUSER|g" geth.conf
sudo -u $AZUREUSER sed -i "s|auguruser|$AZUREUSER|g" augur_ui.conf

sudo touch /var/log/geth.sys.log
sudo touch /var/log/augur_ui.sys.log
sudo chown $AZUREUSER /var/log/geth.sys.log
sudo chown $AZUREUSER /var/log/augur_ui.sys.log

####################
# Setup Geth
####################
sudo -i -u $AZUREUSER geth init genesis.json 
pw=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;`
sudo -i -u $AZUREUSER echo $pw > pw.txt
sudo -i -u $AZUREUSER geth --password pw.txt account import priv_genesis.key

#make geth a service, turn on.
sudo cp geth.conf /etc/init/
sudo start geth

#Pregen DAG so miniing can start immediately
sudo -u $AZUREUSER mkdir .ethash
sudo -i -u $AZUREUSER geth makedag 0 .ethash

####################
#Install Augur Contracts
####################
sudo -i -u $AZUREUSER git clone https://github.com/AugurProject/augur-core.git
cd  augur-core/load_contracts
pip install -r requirements-load.txt
python load_contracts.py
python generate_gospel.py -o contracts.json -n 1101011
contracts=`cat contracts.json`
contracts=$(echo $contracts | sed "s|\"|\'|g")
sudo -u $AZUREUSER sed -i "s|azure_contracts|$contracts|g" $HOMEDIR/env.json
sudo -u $AZUREUSER sed -i "s|azure_contracts|$contracts|g" $HOMEDIR/init_contracts.js
sudo -u $AZUREUSER sed -i "s|\x27|\x22|g" $HOMEDIR/env.json
sudo -u $AZUREUSER sed -i "s|\x27|\x22|g" $HOMEDIR/init_contracts.js
cd ../..
time sudo npm install chai
time sudo npm install chalk
sudo -i -u $AZUREUSER node init_contracts.js

####################
#Make a swap file (node can get hungry)
####################
sudo fallocate -l 128MiB /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

####################
#Install Augur Front End
####################
sudo -i -u $AZUREUSER git clone https://github.com/AugurProject/augur.git
sudo -i -u $AZUREUSER mkdir ui
sudo -i -u $AZUREUSER cp -r augur/azure/* ui
sudo -i -u $AZUREUSER cp $HOMEDIR/env.json ui/
rm -rf augur

###################
#Install augur webserver
####################
sudo -i -u $AZUREUSER git clone https://github.com/AugurProject/augur-ui-webserver.git
sudo -i -u $AZUREUSER  bash -c "cd augur-ui-webserver; npm install"

#allow nodejs to run on port 80 w/o sudo
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/nodejs

#Make augur_ui a service, turn on.
sudo cp augur_ui.conf /etc/init/
start augur_ui 

date
echo "completed augur install $$"
