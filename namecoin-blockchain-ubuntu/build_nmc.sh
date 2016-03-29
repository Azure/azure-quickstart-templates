#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Namecoin    #
#################################################################
sudo apt-get update
#################################################################
# Build Namecoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Namecoin            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/namecoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/namecoin/namecoin-core.git
fi

cd /usr/local/namecoin
file=/usr/local/namecoin/src/namecoind
if [ ! -e "$file" ]
then
	./autogen.sh && ./configure --without-gui
	sudo make
fi

cd /usr/local/hodlcoin/src
sudo make install

################################################################
# Configure to auto start at boot		                           #
################################################################

file=$HOME/.namecoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.namecoin
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.namecoin/namecoin.conf
file=/etc/init.d/namecoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo namecoind' | sudo tee /etc/init.d/namecoin
	sudo chmod +x /etc/init.d/namecoin
	sudo update-rc.d namecoin defaults	
fi

/usr/bin/namecoind
echo "Namecoin has been setup successfully and is running..."
exit 0
