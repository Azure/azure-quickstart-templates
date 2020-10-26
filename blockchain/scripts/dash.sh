#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Dash Core   #
#################################################################
sudo apt-get update
#################################################################
# Build Dash Core from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Dash Core           #
#################################################################
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/dash
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/dashpay/dash.git
fi

cd /usr/local/dash
file=/usr/local/dash/src/dashd
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/dash/src/dashd /usr/bin/dashd
sudo cp /usr/local/dash/src/dash-cli /usr/bin/dash-cli

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=/etc/init.d/dash
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo dashd' | sudo tee /etc/init.d/dash
	sudo chmod +x /etc/init.d/dash
	sudo update-rc.d dash defaults	
fi

/usr/bin/dashd
echo "Dash Core has been setup successfully and is running..."
exit 0
