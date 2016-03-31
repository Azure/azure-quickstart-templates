#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running VPNCoin   #
#################################################################
sudo apt-get update
#################################################################
# Build VPNCoin from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building VPNCoin           #
#################################################################
sudo apt-get install -y libboost1.55-all-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev build-essential libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/vpncoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/Bit-Net/VpnCoin.git vpncoin
fi

cd /usr/local/vpncoin/src
file=/usr/local/vpncoin/src/vpncoind
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/vpncoin/src/vpncoind /usr/bin/vpncoind

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.vpncoin 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.vpncoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.vpncoin/vpncoin.conf
file=/etc/init.d/vpncoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo vpncoind' | sudo tee /etc/init.d/vpncoin
	sudo chmod +x /etc/init.d/vpncoin
	sudo update-rc.d vpncoin defaults	
fi

/usr/bin/vpncoind
echo "VPNCoin has been setup successfully and is running..."
exit 0
