#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Blitz     #
#################################################################
sudo apt-get update
#################################################################
# Build Blitz source                                            #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Blitz             #
#################################################################
sudo apt-get install -y --force qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev build-essential libtool autotools-dev autoconf pkg-config libssl-dev libssl-dev libdb++-dev libssl-dev ufw git libevent-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y --force libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/blitz
if [ ! -e "$file" ]
then
	sudo git clone https://bitbucket.org/blitz-dev/blitz-public.git blitz
fi

cd /usr/local/blitz/src
file=/usr/local/blitz/src/blitzd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/blitz/src/blitzd /usr/bin/blitzd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.blitz 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.blitz
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.blitz/blitz.conf
file=/etc/init.d/blitz
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo blitzd' | sudo tee /etc/init.d/blitz
	sudo chmod +x /etc/init.d/blitz
	sudo update-rc.d blitz defaults	
fi

/usr/bin/blitzd
echo "Blitz has been setup successfully and is running..."
exit 0
