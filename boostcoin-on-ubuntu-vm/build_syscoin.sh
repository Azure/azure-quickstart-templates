#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running BoostCoin-core   #
#################################################################
sudo apt-get update
#################################################################
# Build BoostCoin-core from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building BoostCoin-core           #
#################################################################
sudo apt-get -y install qt4-qmake libqt4-dev build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb4.8-dev libdb4.8++-dev libminiupnpc-dev libevent-dev git
sudo apt-get update

cd /usr/local
file=/usr/local/boostcoin-core
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/mammix2/boostcoin-core.git
fi

cd /usr/local/boostcoin-core
file=/usr/local/boostcoin-core/src/boostcoind
if [ ! -e "$file" ]
then
	sudo make -f makefile.unix -j$NPROC
	sudo strip boostcoind 
fi

sudo cp /usr/local/boostcoin/src/boostcoind /usr/bin/boostcoind

else    
#################################################################
# Install BoostCoin-core from PPA                                      #
#################################################################
sudo add-apt-repository -y ppa:boostcoin/boostcoin
sudo apt-get update
sudo apt-get install -y boostcoin

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=$HOME/.boostcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.boostcoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.boostcoin/boostcoin.conf
file=/etc/init.d/boostcoind
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo boostcoind' | sudo tee /etc/init.d/boostcoind
	sudo chmod +x /etc/init.d/boostcoind
	sudo update-rc.d boostcoind defaults	
fi

/usr/bin/boostcoind
echo "BoostCoin-core has been setup successfully and is running..."
exit 0
