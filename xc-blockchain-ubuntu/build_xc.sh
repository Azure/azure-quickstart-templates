#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running xc    #
#################################################################
sudo apt-get update
#################################################################
# Build xc from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building xc            #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/xc
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/atcsecure/XC_XBridge.git xc
fi

cd /usr/local/xc/src
sudo mkdir obj
sudo mkdir obj/lz4
file=/usr/local/xc/src/XCurrencyd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/xc/src/XCurrencyd /usr/bin/XCurrencyd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.XCurrency
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.XCurrency
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.XCurrency/XCurrency.conf
file=/etc/init.d/XCurrency
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo XCurrencyd' | sudo tee /etc/init.d/XCurrency
	sudo chmod +x /etc/init.d/XCurrency
	sudo update-rc.d XCurrency defaults	
fi

/etc/init.d/XCurrency
echo "xc has been setup successfully and is running..."
exit 0
