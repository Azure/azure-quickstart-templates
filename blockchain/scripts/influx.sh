#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Influx    #
#################################################################
sudo apt-get update
#################################################################
# Build Influx from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Influx            #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/Influx
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/Coryvmcs1/Influxcoin.git Influx
fi

cd /usr/local/Influx/src
file=/usr/local/Influx/src/Influxd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/Influx/src/Influxd /usr/bin/Influxd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.Influx 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.Influx
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.Influx/Influx.conf
file=/etc/init.d/Influx
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo Influxd' | sudo tee /etc/init.d/Influx
	sudo chmod +x /etc/init.d/Influx
	sudo update-rc.d Influx defaults	
fi

/usr/bin/Influxd
echo "Influx has been setup successfully and is running..."
exit 0
