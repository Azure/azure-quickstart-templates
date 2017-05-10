#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Startcoin    #
#################################################################
sudo apt-get update
#################################################################
# Build Startcoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Startcoin            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/startcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/startcoin-project/startcoin
fi

cd /usr/local/startcoin
file=/usr/local/startcoin/src/startcoind
if [ ! -e "$file" ]
then
	cd src
	sudo make -f makefile.unix
fi

sudo cp /usr/local/startcoin/src/startcoind /usr/bin/startcoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.startcoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.startcoin-v2
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1\naddnode=217.160.180.208:9247\naddnode=74.120.220.51:9247\naddnode=46.105.158.205:9247\naddnode=72.130.194.71:9247\naddnode=195.154.223.134:9247\naddnode=104.131.82.220:9247\naddnode=151.80.9.33:9247\naddnode=62.45.120.75:9247" > $HOME/.startcoin-v2/startcoin.conf
file=/etc/init.d/startcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo startcoind' | sudo tee /etc/init.d/startcoin
	sudo chmod +x /etc/init.d/startcoin
	sudo update-rc.d startcoin defaults	
fi

/usr/bin/startcoind
echo "Startcoin has been setup successfully and is running..."
exit 0
