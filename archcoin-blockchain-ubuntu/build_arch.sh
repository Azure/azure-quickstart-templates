#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Archcoin  #
#################################################################
sudo apt-get update
#################################################################
# Build Archcoin from source                                    #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Archcoin          #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/archcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/EdgarSoares/ARCH.git arch
fi

cd /usr/local/arch/src
file=/usr/local/arch/src/archcoind
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/arch/src/archcoind /usr/bin/archcoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.archcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.archcoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.archcoin/archcoin.conf
file=/etc/init.d/archcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo archcoind' | sudo tee /etc/init.d/archcoin
	sudo chmod +x /etc/init.d/archcoin
	sudo update-rc.d archcoin defaults	
fi

/usr/bin/archcoind
echo "Archcoin has been setup successfully and is running..."
exit 0
