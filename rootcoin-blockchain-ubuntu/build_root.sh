#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Rootcoin    #
#################################################################
sudo apt-get update
#################################################################
# Build Rootcoin from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Rootcoin            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/rootcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/bitsta/rootcoin
fi

cd /usr/local/rootcoin
file=/usr/local/rootcoin/src/rootcoind
if [ ! -e "$file" ]
then
	cd src
	sudo make -f makefile.unix
fi

sudo cp /usr/local/rootcoin/src/rootcoind /usr/bin/rootcoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.RootCoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.RootCoin
fi

sudo /bin/su -c "echo 'rpcuser=%s\n' $2 > $HOME/.RootCoin/RootCoin.conf"
sudo /bin/su -c "echo 'rpcpassword=%s\n' $3 >> $HOME/.RootCoin/RootCoin.conf"
sudo /bin/su -c "echo 'rpcport=%s\n' $4 >> $HOME/.RootCoin/RootCoin.conf"
sudo /bin/su -c "echo 'server=1' >> $HOME/.RootCoin/RootCoin.conf"
sudo /bin/su -c "echo 'rpcallowip=%s\n' $5 >> $HOME/.RootCoin/RootCoin.conf"
sudo /bin/su -c "echo 'daemon=1'  >> $HOME/.RootCoin/RootCoin.conf"


file=/etc/init.d/rootcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo rootcoind' | sudo tee /etc/init.d/rootcoin
	sudo chmod +x /etc/init.d/rootcoin
	sudo update-rc.d rootcoin defaults	
fi

sudo chmod -R 777 $HOME/.RootCoin/
/usr/bin/rootcoind
echo "Rootcoin has been setup successfully and is running..."
exit 0
