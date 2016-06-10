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
time sudo apt-get install -y build-essential automake pkg-config libtool libffi-dev libgmp-dev
time sudo apt-get -y install git
time sudo apt-get -y install libssl-dev
time curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
time sudo apt-get -y install nodejs

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
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/geth.conf
sudo -u $AZUREUSER wget https://raw.githubusercontent.com/kevinday/azure-quickstart-templates/master/augur-on-ubuntu/augur_ui.conf
sudo -u $AZUREUSER sed -i "s/auguruser/$AZUREUSER/g" geth.conf
sudo -u $AZUREUSER sed -i "s/auguruser/$AZUREUSER/g" augur_ui.conf

touch /var/log/geth.sys.log
touch /var/log/augur_ui.sys.log
chown $AZUREUSER /var/log/geth.sys.log
chown $AZUREUSER /var/log/augur_ui.sys.log

####################
# Setup Geth
####################
sudo -i -u $AZUREUSER geth init genesis.json 
pw=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;`
sudo -u $AZUREUSER echo $pw > pw.txt
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
cd  augur-core/load_contracts
python load_contracts.py
contracts="`python generate_gospel.py -j`"
contracts=${contracts//\"/\\\"}
contracts=${contracts//[$'\t\r\n ']}
cd ../..

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
sudo -i -u $AZUREUSER mkdir ui
udo -i -u $AZUREUSER cp -r augur/azure ui
rm -rf augur
sudo -u $AZUREUSER find ui -type f -exec sed -i "s|\"{{ \$BUILD_AZURE_WSURL }}\"|null|g" {} \;
sudo -u $AZUREUSER find ui -type f -exec sed -i "s|{{ \$BUILD_AZURE_LOCALNODE }}|$ETHEREUM_HOST_RPC|g" {} \;
sudo -u $AZUREUSER find ui -type f -exec sed -i "s|\"{{ \$BUILD_AZURE_CONTRACTS }}\"|'$contracts'|g" {} \;


###################
#Install augur webserver
####################
git clone https://github.com/AugurProject/augur-ui-webserver.git
sudo -i -u $AZUREUSER  bash -c "cd augur-ui-webserver; npm install"

#allow nodejs to run on port 80 w/o sudo
setcap 'cap_net_bind_service=+ep' /usr/bin/nodejs

#Make augur_ui a service, turn on.
cp augur_ui.conf /etc/init/
start augur_ui 

date
echo "completed augur install $$"
