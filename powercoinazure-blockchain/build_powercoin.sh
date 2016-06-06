#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running powercoin    #
#################################################################
sudo apt-get update
#################################################################
# Build powercoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building powercoin            #
#################################################################

sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/powercoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/powercoinpwr/powercoin powercoin
fi

cd /usr/local/powercoin/src
file=/usr/local/powercoin/src/powercoind
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/powercoin/src/powercoind /usr/bin/powercoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.powercoin
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.powercoin
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.powercoin/powercoin.conf
file=/etc/init.d/powercoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo powercoind' | sudo tee /etc/init.d/powercoin
	sudo chmod +x /etc/init.d/powercoin
	sudo update-rc.d powercoin defaults	
fi

/usr/bin/powercoind
echo "powercoin has been setup successfully and is running..."
exit 0
