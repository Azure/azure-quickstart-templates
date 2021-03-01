#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Syscoin   #
#################################################################
sudo apt-get update
#################################################################
# Build Syscoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Syscoin           #
#################################################################
sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/syscoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/syscoin/syscoin.git
fi

cd /usr/local/syscoin
file=/usr/local/syscoin/src/syscoind
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/syscoin/src/syscoind /usr/bin/syscoind
sudo cp /usr/local/syscoin/src/syscoin-cli /usr/bin/syscoin-cli

else    
#################################################################
# Install Syscoin from PPA                                      #
#################################################################
sudo add-apt-repository -y ppa:syscoin/syscoin
sudo apt-get update
sudo apt-get install -y syscoin

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=$HOME/.syscoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.syscoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.syscoin/syscoin.conf
file=/etc/init.d/syscoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo syscoind' | sudo tee /etc/init.d/syscoin
	sudo chmod +x /etc/init.d/syscoin
	sudo update-rc.d syscoin defaults	
fi

/usr/bin/syscoind
echo "Syscoin has been setup successfully and is running..."
exit 0
