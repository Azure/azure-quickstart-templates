#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Dynamic   #
#################################################################
sudo apt-get update
#################################################################
# Build Dynamic from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Dynamic           #
#################################################################
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/dynamic
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/duality-solutions/dynamic.git
fi

cd /usr/local/dynamic
file=/usr/local/dynamic/src/dynamicd
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/dynamic/src/dynamicd /usr/bin/dynamicd
sudo cp /usr/local/dynamic/src/dynamic-cli /usr/bin/dynamic-cli

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=/etc/init.d/dynamic
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo dynamicd' | sudo tee /etc/init.d/dynamic
	sudo chmod +x /etc/init.d/dynamic
	sudo update-rc.d dynamic defaults	
fi

/usr/bin/dynamicd
echo "Dynamic has been setup successfully and is running..."
exit 0
