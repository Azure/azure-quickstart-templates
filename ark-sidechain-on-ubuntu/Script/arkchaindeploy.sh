#!/bin/bash

# Variables - Current settings are defaults
SIDECHAINNAME=MyTestChain
CHAINTOKEN=MyTestToken
CHAINSYMBOL=MCT
CHAINFORGERS=51
MAXVOTESPERWALLET=1
CHAINBLOCKTIME=8
CHAINTRANSPERBLOCK=50
REWARDSTART=75600
REWARDPERBLOCK=200000000
TOTALPREMINE=2100000000000000
IPADDR=10.0.0.4

~/ark-deployer/sidechain.sh install-node --name $SIDECHAINNAME --database ark_$SIDECHAINNAME --ip $IPADDR --token $CHAINTOKEN --symbol $CHAINSYMBOL --forgers $CHAINFORGERS --max-votes $MAXVOTESPERWALLET --blocktime $CHAINBLOCKTIME --transactions-per-block $CHAINTRANSPERBLOCK --reward-height-start $REWARDSTART --reward-per-block $REWARDPERBLOCK --total-premine $TOTALPREMINE
~/ark-deployer/sidechain.sh start-node --name $SIDECHAINNAME

~/ark-deployer/sidechain.sh install-explorer --name $SIDECHAINNAME --token $CHAINTOKEN --ip $IPADDR
~/ark-deployer/sidechain.sh start-explorer
