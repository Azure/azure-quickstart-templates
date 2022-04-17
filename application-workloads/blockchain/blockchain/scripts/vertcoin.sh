#!/bin/bash

set -e

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
VERTCOINPATH="$HOMEDIR/.vertcoin"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Vertcoin path: $VERTCOINPATH"
echo "vmname: $VMNAME"

if [[ $1 = 'From_Source' ]]; then

#####################################################################@
# Update Ubuntu and install prerequisites for running Vertcoin Core  #
#####################################################################@
sudo apt-get update

#################################################################
# Get CPU count                                                 #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"

##########################################################################
# Install all necessary packages for building Vertcoin Core from source  #
##########################################################################
sudo apt-get -y install software-properties-common build-essential libtool autotools-dev autoconf pkg-config libssl-dev libcrypto++-dev libevent-dev git automake bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev libsqlite3-dev libnatpmp-dev libgmp-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

#################################################################
# Build Vertcoin Core from source                               #
#################################################################
cd /usr/local
file=/usr/local/vertcoin
if [ ! -e "$file" ]
then
	sudo git clone https://github.com/vertcoin-project/vertcoin-core.git vertcoin
fi

cd /usr/local/vertcoin
file=/usr/local/vertcoin/src/vertcoind
if [ ! -e "$file" ]
then
	sudo ./autogen.sh
	sudo ./configure --disable-bench --disable-tests --without-gui
	sudo make -j$NPROC
fi

#################################################################
# Strip executables                                             #
#################################################################
strip /usr/local/vertcoin/src/vertcoind /usr/local/vertcoin/src/vertcoin-cli /usr/local/vertcoin/src/vertcoin-tx /usr/local/vertcoin/src/vertcoin-wallet

#################################################################
# Move executables to /usr/bin                                  #
#################################################################
sudo mv /usr/local/vertcoin/src/vertcoind /usr/local/vertcoin/src/vertcoin-cli /usr/local/vertcoin/src/vertcoin-tx /usr/local/vertcoin/src/vertcoin-wallet /usr/bin

else
#################################################################
# Install Vertcoin Core from PPA (uses libdb5.3)                #
#################################################################
sudo add-apt-repository -y ppa:vertcoin-project/vertcoin-core
sudo apt-get update
sudo apt-get install -y vertcoind vertcoin-tx

fi

################################################################
# Create Vertcoin Core Directory                               #
################################################################
if [ ! -e "$VERTCOINPATH" ]
then
	su - $AZUREUSER -c "mkdir $VERTCOINPATH"
fi

###############################################################################################@
# Install pwgen for generating pronounceable RPC username and password for configuration file  #
################################################################################################
sudo apt-get -y install pwgen

################################################################
# Create configuration File                                    #
################################################################
su - $AZUREUSER -c "touch $VERTCOINPATH/vertcoin.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser="$rpcu"
rpcpassword="$rpcp"
server=1
daemon=1" > $VERTCOINPATH/vertcoin.conf

################################################################
# Configure to auto start at boot                              #
################################################################
file=/etc/init.d/vertcoin
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' '/usr/bin/vertcoind' | sudo tee /etc/init.d/vertcoin
	sudo chmod +x /etc/init.d/vertcoin
	sudo update-rc.d vertcoin defaults
fi

################################################################
# Start Vertcoin Core                                          #
################################################################
su - $AZUREUSER -c "vertcoind"
echo "Vertcoin Core has been setup successfully and is running $$"
exit 0