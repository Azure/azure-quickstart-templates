#!/bin/bash

set -e

date
ps axjf


if [[ $1 = 'From_Source' ]]; then

#################################################################
# Update Ubuntu and install prerequisites for running Groestlcoin Core   #
#################################################################
sudo apt-get update

#################################################################
# Get CPU count                                                          #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"

#################################################################
# Install all necessary packages for building Groestlcoin Core from source  #
#################################################################
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev libdb5.3 libdb5.3-dev libdb5.3++-dev libsqlite3-dev libnatpmp-dev pwgen dialog apt-utils

#################################################################
# Build Groestlcoin Core from source                                     #
#################################################################
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

#################################################################
# Strip executables                                                     #
#################################################################
strip /usr/local/groestlcoind /usr/local/groestlcoin-cli /usr/local/groestlcoin-tx /usr/local/groestlcoin-wallet /usr/local/groestlcoin-util

#################################################################
# Move executables to /usr/bin                                           #
#################################################################
sudo mv /usr/local/groestlcoind /usr/local/groestlcoin-cli /usr/local/groestlcoin-tx /usr/local/groestlcoin-wallet /usr/local/groestlcoin-util /usr/bin

else
#################################################################
# Install Groestlcoin Core from PPA                                      #
#################################################################
sudo add-apt-repository -y ppa:groestlcoin/groestlcoin
sudo apt-get update
sudo apt-get install -y groestlcoind groestlcoin-tx groestlcoin-wallet

fi

################################################################
# Create Groestlcoin Core Directory                                      #
################################################################
file=$HOME/.groestlcoin
if [ ! -e "$file" ]
then
	mkdir $HOME/.groestlcoin
fi

#################################################################
# Install all necessary packages for building Groestlcoin Core from ppa  #
#################################################################
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev libdb5.3 libdb5.3-dev libdb5.3++-dev libsqlite3-dev libnatpmp-dev pwgen dialog apt-utils

################################################################
# Create configuration File                                              #
################################################################
rpcp=$(pwgen -ncsB 35 1)
printf '%s\n%s\n%s\nrpcpassword=%s\n' 'daemon=1' 'server=1' 'rpcuser=groestlcoinrpc' $rpcp | tee $HOME/.groestlcoin/groestlcoin.conf

################################################################
# Configure to auto start at boot                                        #
################################################################
file=/etc/init.d/groestlcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' '/usr/bin/groestlcoind' | sudo tee /etc/init.d/groestlcoin
	sudo chmod +x /etc/init.d/groestlcoin
	sudo update-rc.d groestlcoin defaults
fi

################################################################
# Start Groestlcoin Core                                                 #
################################################################
/usr/bin/groestlcoind
echo "Groestlcoin Core has been setup successfully and is running..."
exit 0
