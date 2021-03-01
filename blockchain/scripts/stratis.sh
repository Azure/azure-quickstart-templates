#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Stratis   #
#################################################################
sudo apt-get update
#################################################################
# Build Stratis from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Stratis           #
#################################################################
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/stratisX
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/stratisproject/stratisX.git
fi

cd /usr/local/stratisX/src
file=/usr/local/stratisX/src/stratisd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/stratisX/src/stratisd /usr/bin/stratisd

################################################################
# Configure to auto start at boot		               #
################################################################
file=$HOME/.stratis 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.stratis
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.stratis/stratis.conf
file=/etc/init.d/stratis
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo stratisd' | sudo tee /etc/init.d/stratis
	sudo chmod +x /etc/init.d/stratis
	sudo update-rc.d stratis defaults	
fi

/usr/bin/stratisd
echo "Stratis has been setup successfully and is running..."
exit 0
