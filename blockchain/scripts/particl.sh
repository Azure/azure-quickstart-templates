#!/bin/bash
set -x

echo "initializing Particl installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
PARTICLPATH="$HOMEDIR/.particl"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Particl path: $PARTICLPATH"
echo "vmname: $VMNAME"


if [ $1 = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/
sudo git clone https://github.com/particl/particl-core 
cd particl/src 
sudo make -f makefile.unix 

sudo cp particld /usr/bin/particld

else    
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/
DOWNLOADFILE=$(curl -s https://github.com/particl/particl-core/releases/download/v0.18.1.6/particl-0.18.1.6-x86_64-linux-gnu.tar.gz)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/particl/particl-core/releases/download/v0.18.1.6/particl-0.18.1.6-x86_64-linux-gnu.tar.gz)
sudo wget $DOWNLOADFILE
sudo unzip $DOWNLOADNAME
sudo cp particld /usr/bin/particld
fi

# Create Client Directory
if [ ! -e "$PARTICLPATH" ]
then
        su - $AZUREUSER -c "mkdir $PARTICLPATH"
fi

# Create configuration File
su - $AZUREUSER -c "touch $PARTICLPATH/particl.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser="$rpcu"
rpcpassword="$rpcp"
daemon=1" > $PARTICLPATH/particl.conf

# Start Particl Client
su - $AZUREUSER -c "particld"

echo "completed Particl install $$"
exit 0
