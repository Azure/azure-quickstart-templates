#!/bin/bash

set -x

echo "initializing Jumbucks installation"

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Jumbucks  #
#################################################################
sudo apt-get update
#################################################################
# Build Jumbucks from source                                    #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Jumbucks          #
#################################################################
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev pwgen
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local/src/
sudo git clone https://github.com/jyap808/jumbucks.git

cd /usr/local/jumbucks/src
file=/usr/local/jumbucks/src/jumbucksd
if [ ! -e "$file" ]
then
	sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/jumbucks/src/jumbucksd /usr/bin/jumbucksd

else
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev pwgen
cd /usr/local/src/
DOWNLOADFILE=$(curl -s https://api.github.com/repos/jyap808/jumbucks/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/jyap808/jumbucks/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
DIRNAME=$(echo $DOWNLOADNAME | sed 's/.tar.gz//')
sudo wget $DOWNLOADFILE
sudo tar zxf $DOWNLOADNAME
sudo cp $DIRNAME/jumbucksd /usr/bin/jumbucksd
fi

################################################################
# Configure to auto start at boot		                       #
################################################################
file=$HOME/.jumbucks 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.jumbucks
fi
rpcp=$(pwgen -ncsB 35 1)
printf '%s\n%s\n%s\nrpcpassword=%s\n' 'daemon=1' 'server=1' 'rpcuser=jumbucksrpc' $rpcp | sudo tee $HOME/.jumbucks/jumbucks.conf
file=/etc/init.d/jumbucks
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo jumbucksd' | sudo tee /etc/init.d/jumbucks
	sudo chmod +x /etc/init.d/jumbucks
	sudo update-rc.d jumbucks defaults
fi

/usr/bin/jumbucksd
echo "Jumbucks has been setup successfully and is running..."
exit 0
