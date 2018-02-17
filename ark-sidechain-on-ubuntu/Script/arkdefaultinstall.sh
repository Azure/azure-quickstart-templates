#!/bin/bash

sudo apt-get -y update
git clone https://github.com/ArkEcosystem/ark-deployer.git 
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.profile 
nvm install 8.9.1
sudo apt-get install -y jq

#Variables for installations - default values input below
IPNODE=
IPEXPLORE=
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

~/ark-deployer/sidechain.sh install-node --name $SIDECHAINNAME --database $DATABASENAME --token $CHAINTOKEN --symbol $CHAINSYMBOL --forgers $CHAINFORGERS --max-votes $MAXVOTESPERWALLET --blocktime $CHAINBLOCKTIME --transactions-per-block $CHAINTRANSPERBLOCK --reward-height-start $REWARDSTART --reward-per-block $REWARDPERBLOCK --total-premine $TOTALPREMINE --autoinstall-deps
~/ark-deployer/sidechain.sh start-node --name $SIDECHAINNAME

~/ark-deployer/sidechain.sh install-explorer --name $SIDECHAINNAME --token $CHAINTOKEN --autoinstall-deps
~/ark-deployer/sidechain.sh start-explorer &>/dev/null &
