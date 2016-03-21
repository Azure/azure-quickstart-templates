#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Jumbucks    #
#################################################################
sudo apt-get update
#################################################################
# Build Jumbucks from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Jumbucks            #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/Jumbucks
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/jyap808/jumbucks.git Jumbucks
fi

cd /usr/local/Jumbucks/src
file=/usr/local/Jumbucks/src/jumbucksd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/Jumbucks/src/jumbucksd /usr/bin/jumbucksd
fi

################################################################
# Configure to auto start at boot		               #
################################################################
file=$HOME/.jumbucks 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.jumbucks
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.jumbucks/jumbucks.conf
file=/etc/init.d/Jumbucks
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo jumbucksd' | sudo tee /etc/init.d/Jumbucks
	sudo chmod +x /etc/init.d/Jumbucks
	sudo update-rc.d Jumbucks defaults	
fi

/usr/bin/jumbucksd
echo "Jumbucks has been setup successfully and is running..."
exit 0
