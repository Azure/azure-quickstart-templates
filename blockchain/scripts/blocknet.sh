#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Blocknet  #
#################################################################
sudo apt-get update
#################################################################
# Build Blocknet source                                         #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Blocknet          #
#################################################################
sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/blocknet
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/atcsecure/blocknet.git blocknet
fi

cd /usr/local/blocknet/src
mkdir obj
file=/usr/local/blocknet/src/blocknetd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/blocknet/src/blocknetd /usr/bin/blocknetd

################################################################
# Configure to auto start at boot		               #
################################################################
file=$HOME/.blocknet 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.blocknet
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.blocknet/blocknet.conf
file=/etc/init.d/blocknet
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo blocknetd' | sudo tee /etc/init.d/blocknet
	sudo chmod +x /etc/init.d/blocknet
	sudo update-rc.d blocknet defaults	
fi

/usr/bin/blocknetd
echo "Blocknet has been setup successfully and is running..."
exit 0
