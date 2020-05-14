#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Sequence   #
#################################################################
sudo apt-get update
#################################################################
# Build Sequence from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Sequence           #
#################################################################
sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev libboost-all-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/sequence
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/duality-solutions/sequence.git
fi

cd /usr/local/sequence
file=/usr/local/sequence/src/sequenced
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/sequence/src/sequenced /usr/bin/sequenced
sudo cp /usr/local/sequence/src/sequence-cli /usr/bin/sequence-cli

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=/etc/init.d/sequence
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo sequenced' | sudo tee /etc/init.d/sequence
	sudo chmod +x /etc/init.d/sequence
	sudo update-rc.d sequence defaults	
fi

/usr/bin/sequenced
echo "Sequence has been setup successfully and is running..."
exit 0
