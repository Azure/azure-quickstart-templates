#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running GeoCoin    #
#################################################################
sudo apt-get update
#################################################################
# Build GeoCoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building GeoCoin            #
#################################################################

sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/geocoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/onetimer/onetimer geocoin
fi

cd /usr/local/geocoin/src
file=/usr/local/geocoin/src/geocoind
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/geocoin/src/geocoind /usr/bin/geocoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.geocoin
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.geocoin
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.geocoin/geocoin.conf
file=/etc/init.d/geocoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo geocoind' | sudo tee /etc/init.d/geocoin
	sudo chmod +x /etc/init.d/geocoin
	sudo update-rc.d geocoin defaults	
fi

/usr/bin/geocoind
echo "GeoCoin has been setup successfully and is running..."
exit 0
