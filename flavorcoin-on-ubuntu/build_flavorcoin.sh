#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running FlavorCoin    #
#################################################################
sudo apt-get update
#################################################################
# Build FlavorCoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building FlavorCoin            #
#################################################################

sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/flavorcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/flavorcoin/FlavorCoin-V2 flavorcoin
fi

cd /usr/local/flavorcoin/src
file=/usr/local/flavorcoin/src/FlavorCoind
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/flavorcoin/src/FlavorCoind /usr/bin/FlavorCoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.FlavorCoin
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.FlavorCoin
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.FlavorCoin/FlavorCoin.conf
file=/etc/init.d/flavorcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo FlavorCoind' | sudo tee /etc/init.d/flavorcoin
	sudo chmod +x /etc/init.d/flavorcoin
	sudo update-rc.d flavorcoin defaults	
fi

/usr/bin/FlavorCoind
echo "FlavorCoin has been setup successfully and is running..."
exit 0
