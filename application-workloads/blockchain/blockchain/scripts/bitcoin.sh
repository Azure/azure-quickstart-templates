#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Bitcoin Core   #
#################################################################
sudo apt-get update
#################################################################
# Build Bitcoin Core from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Bitcoin Core           #
#################################################################
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/bitcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/bitcoin/bitcoin.git
fi

cd /usr/local/bitcoin
file=/usr/local/bitcoin/src/bitcoind
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/bitcoin/src/bitcoind /usr/bin/bitcoind
sudo cp /usr/local/bitcoin/src/bitcoin-cli /usr/bin/bitcoin-cli

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=/etc/init.d/bitcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo bitcoind' | sudo tee /etc/init.d/bitcoin
	sudo chmod +x /etc/init.d/bitcoin
	sudo update-rc.d bitcoin defaults	
fi

/usr/bin/bitcoind
echo "Bitcoin Core has been setup successfully and is running..."
exit 0
