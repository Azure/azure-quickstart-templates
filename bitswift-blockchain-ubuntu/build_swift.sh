#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Bitswift #
#################################################################
sudo apt-get update
#################################################################
# Build Bitswift from source                                    #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Bitswift          #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/bitswift
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/BitSwift-v2/bitswift.git bitswift
fi

cd /usr/local/bitswift/src
file=/usr/local/bitswift/src/bitswiftd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/bitswift/src/bitswiftd /usr/bin/bitswiftd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.bitswift 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.bitswift
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.bitswift/bitswift.conf
file=/etc/init.d/bitswift
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo bitswiftd' | sudo tee /etc/init.d/bitswift
	sudo chmod +x /etc/init.d/bitswift
	sudo update-rc.d bitswift defaults	
fi

/usr/bin/bitswiftd
echo "Bitswift has been setup successfully and is running..."
exit 0
