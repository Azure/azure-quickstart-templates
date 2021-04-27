#!/bin/bash

set -e

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Groestlcoin Core   #
#################################################################
sudo apt-get update
#################################################################
# Build Groestlcoin Core from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Groestlcoin Core           #
#################################################################
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev libdb5.3 libdb5.3-dev libdb5.3++-dev libsqlite3-dev libnatpmp-dev

cd /usr/local
file=/usr/local/groestlcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/groestlcoin/groestlcoin.git
fi

cd /usr/local/groestlcoin
file=/usr/local/groestlcoin/src/groestlcoind
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/groestlcoin/src/groestlcoind /usr/bin/groestlcoind
sudo cp /usr/local/groestlcoin/src/groestlcoin-cli /usr/bin/groestlcoin-cli
sudo cp /usr/local/groestlcoin/src/groestlcoin-tx /usr/bin/groestlcoin-tx
sudo cp /usr/local/groestlcoin/src/groestlcoin-wallet /usr/bin/groestlcoin-wallet
sudo cp /usr/local/groestlcoin/src/groestlcoin-util /usr/bin/groestlcoin-util

else
#################################################################
# Install Groestlcoin Core from PPA                                      #
#################################################################
sudo add-apt-repository -y ppa:groestlcoin/groestlcoin
sudo apt-get update
sudo apt-get install -y groestlcoind groestlcoin-tx groestlcoin-wallet

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=/etc/init.d/groestlcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo groestlcoind' | sudo tee /etc/init.d/groestlcoin
	sudo chmod +x /etc/init.d/groestlcoin
	sudo update-rc.d groestlcoin defaults
fi

/usr/bin/groestlcoind
echo "Groestlcoin Core has been setup successfully and is running..."
exit 0
