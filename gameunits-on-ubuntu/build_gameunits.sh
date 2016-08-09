#!/bin/bash
set -x

echo "initializing Gameunits installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
GAMEUNITSPATH="$HOMEDIR/.gameunits"
VMNAME=$(hostname)
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Gameunits path: $GAMEUNITSPATH"
echo "vmname: $VMNAME"


if [ "$1" = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/ || exit
sudo git clone https://github.com/gameunits/gameunits 
cd gameunits/src || exit
sudo make -f makefile.unix 
sudo strip gameunitsd
sudo cp gameunitsd /usr/bin/gameunitsd

else    
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
cd /usr/local/src/ || exit
DOWNLOADFILE=$(curl -s https://api.github.com/repos/gameunits/gameunits/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/gameunits/gameunits/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget "$DOWNLOADFILE"
sudo unzip "$DOWNLOADNAME"
sudo chmod 755 gameunitsd
sudo cp gameunitsd /usr/bin/gameunitsd
fi

# Create Client Directory
if [ ! -e "$GAMEUNITSPATH" ]
then
        su - "$AZUREUSER" -c "mkdir $GAMEUNITSPATH"
fi

# Download Gameunits Blockchain
su - "$AZUREUSER" -c "cd $GAMEUNITSPATH; wget https://github.com/gameunits/gameunits-blockchain/releases/download/latest/gameunits-blockchain.zip"
su - "$AZUREUSER" -c "cd $GAMEUNITSPATH; unzip gameunits-blockchain.zip"

# Create configuration File
su - "$AZUREUSER" -c "touch $GAMEUNITSPATH/gameunits.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser=$rpcu
rpcpassword=$rpcp
daemon=1" > "$GAMEUNITSPATH"/gameunits.conf

# Start Gameunits Client
su - "$AZUREUSER" -c "gameunitsd"

echo "completed Gameunits install $$"
exit 0
