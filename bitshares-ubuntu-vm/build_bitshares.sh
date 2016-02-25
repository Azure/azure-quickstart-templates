#!/bin/bash

# print commands and arguments as they are executed
set -x

#echo "starting ubuntu devbox install on pid $$"
date
ps axjf

################################################################
# Start a screen session to allow viewing of progress via SSH  #
################################################################
sudo screen 

#############
# Parameters
#############
NPROC=$(nproc)
echo "nproc: $NPROC"

################################################################
# Update Ubuntu and install all necessary prerequisites        #
################################################################

time apt-get -y update
time apt-get -y install git ntp cmake libbz2-dev libdb++-dev libdb-dev libssl-dev openssl libreadline-dev autoconf libtool libboost-all-dev

################################################################
# Build BitShares from source, then start witness node         #
################################################################
cd ~/ 
time sudo git clone https://github.com/bitshares/bitshares-2.git 
cd ~/bitshares-2 
time sudo git submodule update --init --recursive --force 
time sudo cmake -DCMAKE_BUILD_TYPE=Release . 
time sudo make -j$NPROC

cd ~/bitshares-2/programs/witness_node
sudo ./witness_node --rpc-endpoint=127.0.0.1:8090

################################################################
# Connect to the host via SSH                                  #
# sudo ~/bitshares/programs/cli_wallet/./cli_wallet            #
################################################################
