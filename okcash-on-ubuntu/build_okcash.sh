#!/bin/bash
set -x

echo "initializing Okcash installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
OKCASHPATH="$HOMEDIR/.okcash"
VMNAME=$(hostname)
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Okcash path: $OKCASHPATH"
echo "vmname: $VMNAME"


if [ "$1" = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/ || exit
sudo git clone https://github.com/okcashpro/okcash 
cd okcash/src || exit
sudo make -f makefile.unix 
sudo strip okcashd
sudo cp okcashd /usr/bin/okcashd

else    
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/ || exit
DOWNLOADFILE=$(curl -s https://api.github.com/repos/okcashpro/okcash/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/okcashpro/okcash/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget "$DOWNLOADFILE"
sudo unzip "$DOWNLOADNAME"
sudo chmod 755 okcashd
sudo cp okcashd /usr/bin/okcashd
fi

# Create Client Directory
if [ ! -e "$OKCASHPATH" ]
then
        su - "$AZUREUSER" -c "mkdir $OKCASHPATH"
fi

# Download OK Blockchain
su - "$AZUREUSER" -c "cd $OKCASHPATH; wget https://github.com/okcashpro/ok-blockchain/releases/download/latest/ok-blockchain.zip"
su - "$AZUREUSER" -c "cd $OKCASHPATH; unzip ok-blockchain.zip"

# Create configuration File
su - "$AZUREUSER" -c "touch $OKCASHPATH/okcash.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser=$rpcu
rpcpassword=$rpcp
daemon=1" > "$OKCASHPATH"/okcash.conf

# Start Okcash Client
su - "$AZUREUSER" -c "okcashd"

echo "completed Okcash install $$"
exit 0