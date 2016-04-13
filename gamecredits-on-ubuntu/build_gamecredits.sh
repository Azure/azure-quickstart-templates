#!/bin/bash

set -e 

date
ps axjf


if [ $1 = 'From_Source' ]; then
#################################################################
# Update Ubuntu and install prerequisites for running Gamecredits   #
#################################################################
sudo apt-get update
#################################################################
# Build Gamecredits from source                                     #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Gamecredits           #
#################################################################
sudo apt-get -y install git unzip wget build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/GameCredits
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/gamecredits-project/GameCredits.git
fi

cd /usr/local/GameCredits
file=/usr/local/GameCredits/src/gamecreditsd
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure
	sudo make -j$NPROC
fi

sudo cp /usr/local/GameCredits/src/gamecreditsd /usr/bin/gamecreditsd
sudo cp /usr/local/GameCredits/src/gamecredits-cli /usr/bin/gamecredits-cli

else    
#################################################################
# Install Gamecredits from PPA                                  #
#################################################################
#sudo add-apt-repository -y ppa:gamecredits/gamecredits
#sudo apt-get update
#sudo apt-get install -y gamecredits
cd /usr/local/src/
DOWNLOADFILE=$(curl -s https://api.github.com/repos/gamecredits-project/GameCredits/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/gamecredits-project/GameCredits/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget $DOWNLOADFILE
sudo unzip $DOWNLOADNAME
sudo cp gamecreditsd /usr/bin/gamecreditsd
sudo cp gamecredits-cli /usr/bin/gamecredits-cli

fi

################################################################
# Configure to auto start at boot					    #
################################################################
file=$HOME/.gamecredits 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.gamecredits
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.gamecredits/gamecredits.conf
file=/etc/init.d/gamecredits
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'sudo gamecreditsd' | sudo tee /etc/init.d/gamecredits
	sudo chmod +x /etc/init.d/gamecredits
	sudo update-rc.d gamecredits defaults	
fi

/usr/bin/gamecreditsd
echo "Gamecredits has been setup successfully and is running... Have Fun ..."
exit 0
