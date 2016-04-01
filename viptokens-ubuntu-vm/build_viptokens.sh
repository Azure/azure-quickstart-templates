#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running vipcoin #
#################################################################
sudo apt-get update
#################################################################
# Build vipcoin from source                                    #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building vipcoin          #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/vipcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/vipcoin/vip vipcoin
fi

cd /usr/local/vipcoin/src
file=/usr/local/vipcoin/src/vipcoind
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/vipcoin/src/vipcoind /usr/bin/vipcoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.vipcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.vipcoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.vipcoin/vipcoin.conf
file=/etc/init.d/vipcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo vipcoind' | sudo tee /etc/init.d/vipcoin
	sudo chmod +x /etc/init.d/vipcoin
	sudo update-rc.d vipcoin defaults	
fi

/usr/bin/vipcoind
echo "vipcoin has been setup successfully and is running..."
exit 0
