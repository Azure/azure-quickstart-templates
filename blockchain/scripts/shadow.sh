#!/bin/bash
set -x

echo "initializing Shadow installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
SHADOWPATH="$HOMEDIR/.shadowcoin"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Shadow path: $SHADOWPATH"
echo "vmname: $VMNAME"


if [ $1 = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/
sudo git clone https://github.com/ShadowProject/shadow 
cd shadow/src 
sudo make -f makefile.unix 

sudo cp shadowcoind /usr/bin/shadowcoind

else    
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/
DOWNLOADFILE=$(curl -s https://api.github.com/repos/shadowproject/shadow/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/shadowproject/shadow/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget $DOWNLOADFILE
sudo unzip $DOWNLOADNAME
sudo cp shadowcoind /usr/bin/shadowcoind
fi

# Create Client Directory
if [ ! -e "$SHADOWPATH" ]
then
        su - $AZUREUSER -c "mkdir $SHADOWPATH"
fi

# Download Blockchain
su - $AZUREUSER -c "cd $SHADOWPATH; wget https://github.com/ShadowProject/blockchain/releases/download/latest/blockchain.zip"
su - $AZUREUSER -c "cd $SHADOWPATH; unzip blockchain.zip"

# Create configuration File
su - $AZUREUSER -c "touch $SHADOWPATH/shadowcoin.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser="$rpcu"
rpcpassword="$rpcp"
daemon=1" > $SHADOWPATH/shadowcoin.conf

# Start Shadow Client
su - $AZUREUSER -c "shadowcoind"

echo "completed Shadow install $$"
exit 0
