#!/bin/bash

# print commands and arguments as they are executed
set -x

#echo "starting ubuntu devbox install on pid $$"
date
ps axjf

################################################################
# Build BitShares from source                                  #
################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
################################################################
# Update Ubuntu and install all necessary prerequisites        #
################################################################
#time apt-get -y update && apt-get -y install dphys-swapfile git ntp cmake libbz2-dev libdb++-dev libdb-dev libssl-dev openssl libreadline-dev autoconf libtool libboost-all-dev

#cd /usr/local
#time git clone https://github.com/bitshares/bitshares-2.git
#cd bitshares-2/
#time git submodule update --init --recursive --force
#time cmake -DCMAKE_BUILD_TYPE=Release .
#time make -j$NPROC
#
#printf '%s\n%s\n' '#!/bin/sh' '/usr/local/bitshares-2/programs/witness_node/witness_node --rpc-endpoint=127.0.0.1:8090' >> /etc/init.d/bitshares
#chmod +x /etc/init.d/bitshares
#update-rc.d bitshares defaults

################################################################
# Install BitShares from PPA                                   #
################################################################
time add-apt-repository -y ppa:bitshares/bitshares
time apt-get -y update && apt-get -y install dphys-swapfile ntp
time apt-get install -y bitshares

printf '%s\n%s\n' '#!/bin/sh' '/usr/local/bitshares-2/programs/witness_node/witness_node --rpc-endpoint=127.0.0.1:8090' >> /etc/init.d/bitshares
chmod +x /etc/init.d/bitshares
update-rc.d bitshares defaults

################################################################
# BitShares installed. After reboot node will auto start       #
################################################################
reboot

################################################################
# Connect to the host via SSH, then start cli wallet           #
# sudo /usr/local/bitshares-2/programs/cli_wallet/cli_wallet   #
################################################################