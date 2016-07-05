#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running ecchi    #
#################################################################
sudo apt-get update
#################################################################
# Build ecchi from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building ecchi            #
#################################################################

sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/ecchi
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/ecchiblockchain/ecchi
fi

cd /usr/local/ecchi/src
file=/usr/local/ecchi/src/ecchid
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/ecchi/src/ecchid /usr/bin/ecchid

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.ecchi
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.ecchi
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.ecchi/ecchi.conf
file=/etc/init.d/ecchi
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo ecchid' | sudo tee /etc/init.d/ecchi
	sudo chmod +x /etc/init.d/ecchi
	sudo update-rc.d ecchi defaults	
fi

/usr/bin/ecchid
echo "ecchi has been setup successfully and is running..."
exit 0
