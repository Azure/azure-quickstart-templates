#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "starting ubuntu devbox install on pid $$"
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

#######################################################
# Update Ubuntu and install all necessary prerequisites
#######################################################

time sudo apt-get -y update
time sudo apt-get -y --force-yes install libbz2-dev libdb++-dev libdb-dev libssl-dev openssl libreadline-dev autoconf libtool git ntp libboost-all-dev

###############################
# Install BitShares from source
###############################
sudo screen 

cd ~/ 
sudo git clone https://github.com/bitshares/bitshares-2.git 
cd ~/bitshares-2 
sudo git submodule update --init --recursive --force 
sudo cmake -DCMAKE_BUILD_TYPE=Release . 
sudo make -j$2

cd ~/bitshares-2/programs/witness_node
sudo ./witness_node --rpc-endpoint=127.0.0.1:8090
