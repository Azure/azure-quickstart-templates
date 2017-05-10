#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Primecoin    #
#################################################################
sudo apt-get update
#################################################################
# Build Primecoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Primecoin            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/primecoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/primecoin/primecoin
fi

cd /usr/local/primecoin
file=/usr/local/primecoin/src/primecoind
if [ ! -e "$file" ]
then
	cd src
	sudo make -f makefile.unix
fi

sudo cp /usr/local/primecoin/src/primecoind /usr/bin/primecoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.primecoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.primecoin
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.primecoin/primecoin.conf
file=/etc/init.d/primecoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo primecoind' | sudo tee /etc/init.d/primecoin
	sudo chmod +x /etc/init.d/primecoin
	sudo update-rc.d primecoin defaults	
fi

/usr/bin/primecoind
echo "Primecoin has been setup successfully and is running..."
exit 0
