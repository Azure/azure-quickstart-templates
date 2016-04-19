#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running thecreed    #
#################################################################
sudo apt-get update
#################################################################
# Build thecreed from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building thecreed            #
#################################################################

sudo apt-get install -y git qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools build-essential libboost-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libevent-dev libminiupnpc-dev libqrencode-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/thecreed
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/thecreedcurrency/TCR thecreed
fi

cd /usr/local/thecreed/src
file=/usr/local/thecreed/src/thecreedd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/thecreed/src/thecreedd /usr/bin/thecreedd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.thecreed
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.thecreed
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.thecreed/thecreed.conf
file=/etc/init.d/thecreed
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo thecreedd' | sudo tee /etc/init.d/thecreed
	sudo chmod +x /etc/init.d/thecreed
	sudo update-rc.d thecreed defaults	
fi

/usr/bin/thecreedd
echo "thecreed has been setup successfully and is running..."
exit 0
