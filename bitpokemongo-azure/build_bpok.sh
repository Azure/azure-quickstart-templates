#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running bpok    #
#################################################################
sudo apt-get update
#################################################################
# Build bpok from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building bpok            #
#################################################################

sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/bpok
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/bpokemon/bitpokemongo
fi

cd /usr/local/bpok/src
file=/usr/local/bpok/src/bpokd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/bpok/src/bpokd /usr/bin/bpokd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.bpok
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.bpok
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.bpok/bitpokemongo.conf
file=/etc/init.d/bpok
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo bpokd' | sudo tee /etc/init.d/bpok
	sudo chmod +x /etc/init.d/bpok
	sudo update-rc.d bpok defaults	
fi

/usr/bin/bpokd
echo "bpok has been setup successfully and is running..."
exit 0
