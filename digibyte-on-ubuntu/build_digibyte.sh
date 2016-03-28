#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running DigiByte   #
#################################################################
sudo apt-get update
#################################################################
# Build DigiByte from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building DigiByte           #
#################################################################
sudo apt-get -y install git build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev pwgen
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/digibyte
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/digibyte/digibyte.git
fi

cd /usr/local/digibyte
file=/usr/local/digibyte/src/digibyted
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/digibyte/src/digibyted /usr/bin/digibyted
sudo cp /usr/local/digibyte/src/digibyte-cli /usr/bin/digibyte-cli

else    
#################################################################
# Install DigiByte from PPA                                      #
#################################################################
sudo add-apt-repository -y ppa:digibyte/digibyte
sudo apt-get update
sudo apt-get install -y digibyte

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=$HOME/.digibyte 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.digibyte
fi
rpcp=$(pwgen -ncsB 35 1)
printf '%s\n%s\n%s\nrpcpassword=%s\n' 'daemon=1' 'server=1' 'rpcuser=digibyterpc' $rpcp | sudo tee $HOME/.digibyte/digibyte.conf
file=/etc/init.d/digibyte
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo digibyted' | sudo tee /etc/init.d/digibyte
	sudo chmod +x /etc/init.d/digibyte
	sudo update-rc.d digibyte defaults	
fi

/usr/bin/digibyted
echo "Digibyte has been setup successfully and is running..."
exit 0
