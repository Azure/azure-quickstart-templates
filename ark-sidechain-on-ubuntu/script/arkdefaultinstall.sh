#!/bin/bash
echo "running update"
sudo apt-get -y update

echo "downloading ark-deployer"
git clone https://github.com/ArkEcosystem/ark-deployer.git 

echo "downloading nvm"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

echo "sourcing nvm and running install"
. ~/.nvm/nvm.sh
. ~/.profile
. ~/.bashrc
nvm install 8.9.1
sudo apt-get install -y jq

#Variables for installations
PUBLICIP="$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')"
AZUREIP=10.0.0.4
SIDECHAINNAME=MyTest
DATABASENAME=ark_mytest
CHAINTOKEN=MYTEST
CHAINSYMBOL=MCT
CHAINFORGERS=51
MAXVOTESPERWALLET=1
CHAINBLOCKTIME=8
CHAINTRANSPERBLOCK=50
REWARDSTART=75600
REWARDPERBLOCK=200000000
TOTALPREMINE=2100000000000000

echo "Beginning ark node installation"
~/ark-deployer/sidechain.sh install-node --name $SIDECHAINNAME --database $DATABASENAME --token $CHAINTOKEN --symbol $CHAINSYMBOL --ip $PUBLICIP --forgers $CHAINFORGERS --max-votes $MAXVOTESPERWALLET --blocktime $CHAINBLOCKTIME --transactions-per-block $CHAINTRANSPERBLOCK --reward-height-start $REWARDSTART --reward-per-block $REWARDPERBLOCK --total-premine $TOTALPREMINE --autoinstall-deps

echo "Start-node for the new sidechain"
~/ark-deployer/sidechain.sh start-node --name $SIDECHAINNAME &>/dev/null &

echo "installing explorer"
~/ark-deployer/sidechain.sh install-explorer --name $SIDECHAINNAME --token $CHAINTOKEN --ip $PUBLICIP --autoinstall-deps

echo "Changing IP address in ~/ark-explorer/package.json to the private IP for Azure"
sed -i "s/$PUBLICIP/$AZUREIP/g" ~/ark-explorer/package.json

echo "Starting ark explorer"
~/ark-deployer/sidechain.sh start-explorer &>/dev/null &

echo "Ark explorer is now started at http://$PUBLICIP:4200 - Give it a couple of minutes to start up!"
