#!/bin/bash

set -e 

date
ps axjf

#####################################################################
# Update Ubuntu and install prerequisites for running Rubies-core   #
#####################################################################
sudo apt-get update
sudo apt-get upgrade -y
#####################################################################
# Build Rubies from source                                          #
#####################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#####################################################################
# Install all necessary packages for building Rubies                #
#####################################################################
sudo apt-get -y install qt4-qmake libqt4-dev build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libminiupnpc-dev git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/rubies-core
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/BetterBetsLobos/rubies-core.git
fi

cd /usr/local/rubies-core/src/leveldb
sudo chmod +x ./build_detect_platform

cd /usr/local/rubies-core/src
file=/usr/local/rubies-core/src/rubiesd
if [ ! -e "$file" ]
then
	sudo make -f makefile.unix -j$NPROC
	sudo strip rubiesd 
fi

sudo cp /usr/local/rubies-core/src/rubiesd /usr/bin/rubiesd


#################################################################
# Configure to auto start at boot				#
#################################################################
file=$HOME/.rubies 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.rubies
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=j34GGdfhekk88fhgeger4' 'rpcpassword=asdfgh4erfvhjy5rxEFH!!!!ff' | sudo tee $HOME/.rubies/rubies.conf
file=/etc/init.d/rubiesd
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo rubiesd' | sudo tee /etc/init.d/rubiesd
	sudo chmod +x /etc/init.d/rubiesd
	sudo update-rc.d rubiesd defaults	
fi

sudo /usr/bin/rubiesd
echo "Rubies-core has been setup successfully. Run 'rubiesd help' for a list of available commands"
exit 0
