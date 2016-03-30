#!/bin/bash

set -e 

date
ps axjf

########################################################################
# Update Ubuntu and install prerequisites for running BoostCoin-core   #
########################################################################
sudo apt-get update
sudo apt-get upgrade -y
########################################################################
# Build BoostCoin-core from source                                     #
########################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
########################################################################
# Install all necessary packages for building BoostCoin-core           #
########################################################################
sudo apt-get -y install qt4-qmake libqt4-dev build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libminiupnpc-dev libevent-dev git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/boostcoin-core
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/mammix2/boostcoin-core.git
fi

cd /usr/local/boostcoin-core/src
file=/usr/local/boostcoin-core/src/boostcoind
if [ ! -e "$file" ]
then
	sudo make -f makefile.unix -j$NPROC
	sudo strip boostcoind 
fi

sudo cp /usr/local/boostcoin-core/src/boostcoind /usr/bin/boostcoind


#################################################################
# Configure to auto start at boot				#
#################################################################
file=$HOME/.boostcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.boostcoin
fi
printf '%s\n%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=f343gf88ja1WWEQ53t!!sg' 'rpcpassword=aRudu!MMetgdhheg1' 'torproxy=1' | sudo tee $HOME/.boostcoin/boostcoin.conf
file=/etc/init.d/boostcoind
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo boostcoind' | sudo tee /etc/init.d/boostcoind
	sudo chmod +x /etc/init.d/boostcoind
	sudo update-rc.d boostcoind defaults	
fi

sudo /usr/bin/boostcoind
echo "BoostCoin-core has been setup successfully. Run 'boostcoind help' for a list of available commands"
exit 0