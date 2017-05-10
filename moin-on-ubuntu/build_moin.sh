#!/bin/bash
set -x

echo "initializing MOIN installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
MOINPATH="$HOMEDIR/.moin"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User MOIN path: $MOINPATH"
echo "vmname: $VMNAME"


if [ $1 = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/
sudo git clone https://github.com/MOIN/moin
cd moin/src 
sudo make -f makefile.unix 

sudo cp moind /usr/bin/moind

else    
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/
DOWNLOADFILE=$(curl -s https://api.github.com/repos/MOIN/MOIN/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/MOIN/MOIN/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget $DOWNLOADFILE
sudo unzip $DOWNLOADNAME
sudo cp moind /usr/bin/moind
fi

# Create Client Directory
if [ ! -e "$MOINPATH" ]
then
        su - $AZUREUSER -c "mkdir $MOINPATH"
fi

# Download Blockchain
su - $AZUREUSER -c "cd $MOINPATH; wget https://github.com/MOIN/blockchain/releases/download/latest/blockchain.zip"
su - $AZUREUSER -c "cd $MOINPATH; unzip blockchain.zip"

# Create configuration File
su - $AZUREUSER -c "touch $MOINPATH/moin.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser="$rpcu"
rpcpassword="$rpcp"
daemon=1" > $MOINPATH/moin.conf

# Start MOIN Client
su - $AZUREUSER -c "moind"

echo "completed MOIN install $$"
exit 0
