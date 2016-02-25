#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "starting ubuntu devbox install on pid $$"
date
ps axjf

#############
# Parameters
#############

NPROC=$(nproc)
echo "nproc: $NPROC"

#######################################################
# Update Ubuntu and install all necessary prerequisites
#######################################################

time sudo apt-get -y update
#time sudo apt-get -y --force-yes install libbz2-dev libdb++-dev libdb-dev libssl-dev openssl libreadline-dev autoconf libtool git cmake ntp libboost-all-dev

###############################
# Install BitShares from source
###############################
#sudo screen 
#
#cd ~/ 
#time sudo git clone https://github.com/bitshares/bitshares-2.git 
#cd ~/bitshares-2 
#time sudo git submodule update --init --recursive --force 
#time sudo cmake -DCMAKE_BUILD_TYPE=Release . 
#time sudo make -j $NPROC
#
#cd ~/bitshares-2/programs/witness_node
#sudo ./witness_node --rpc-endpoint=127.0.0.1:8090
