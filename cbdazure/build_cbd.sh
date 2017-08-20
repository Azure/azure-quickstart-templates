#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running cbd    #
#################################################################
sudo apt-get update
#################################################################
# Build cbd from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building cbd            #
#################################################################

apt-get update && apt-get upgrade
apt-get install ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev

wget http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz && tar -zxf download.php\?file\=miniupnpc-1.8.tar.gz && cd miniupnpc-1.8/
make && make install && cd .. && rm -rf miniupnpc-1.8 download.php\?file\=miniupnpc-1.8.tar.gz

cd /usr/local
file=/usr/local/cbd
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/cbd74/cbd 
fi

cd /usr/local/cbd/src
file=/usr/local/cbd/src/cbdd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/cbd/src/cbdd /usr/bin/cbdd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.cbd
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.cbd
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.cbd/cbd.conf
file=/etc/init.d/cbd
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo cbdd' | sudo tee /etc/init.d/cbd
	sudo chmod +x /etc/init.d/cbd
	sudo update-rc.d cbd defaults	
fi

/usr/bin/cbdd
echo "cbd has been setup successfully and is running..."
exit 0
