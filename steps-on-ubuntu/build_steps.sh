#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Steps    #
#################################################################
sudo apt-get update
#################################################################
# Build Steps from source                                      #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Steps            #
#################################################################

sudo apt-get install -y checkinstall subversion git git-core libssl-dev libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev build-essential libboost-all-dev automake libtool autoconf pkg-config

cd /usr/local
file=/usr/local/steps
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/AltcoinSteps/STEPS
fi

cd /usr/local/steps
file=/usr/local/steps/src/Stepsd
if [ ! -e "$file" ]
then
	cd src
	sudo make -f makefile.unix
fi

sudo cp /usr/local/steps/src/Stepsd /usr/bin/Stepsd

################################################################
# Configure to auto start at boot		                           #
################################################################
file=$HOME/.Steps
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.Steps
fi
echo -e "rpcuser=rpc\nrpcpassword=1234\nserver=1\ndaemon=1" > $HOME/.Steps/Steps.conf
file=/etc/init.d/steps
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo Stepsd' | sudo tee /etc/init.d/steps
	sudo chmod +x /etc/init.d/steps
	sudo update-rc.d steps defaults	
fi

/usr/bin/Stepsd
echo "Steps has been setup successfully and is running..."
exit 0
