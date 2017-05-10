#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Hodlcoin    #
#################################################################
sudo apt-get update
#################################################################
# Build Hodlcoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Hodlcoin            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/hodlcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/HOdlcoin/HOdlcoin hodlcoin
fi

cd /usr/local/hodlcoin
file=/usr/local/hodlcoin/src/hodlcoind
if [ ! -e "$file" ]
then
	./autogen.sh && ./configure --without-gui
	make
fi

sudo cp /usr/local/hodlcoin/src/hodlcoind /usr/bin/hodlcoind
cd /usr/local/hodlcoin/src
sudo make install

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.hodlcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.hodlcoin
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.hodlcoin/hodlcoin.conf
file=/etc/init.d/hodlcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo hodlcoind' | sudo tee /etc/init.d/hodlcoin
	sudo chmod +x /etc/init.d/hodlcoin
	sudo update-rc.d hodlcoin defaults	
fi

/usr/bin/hodlcoind
echo "Hodlcoin has been setup successfully and is running..."
exit 0
