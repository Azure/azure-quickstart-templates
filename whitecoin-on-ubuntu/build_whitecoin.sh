#!/bin/bash
set -x
​
echo "initializing Whitecoin installation"
​
date
ps axjf
​
AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
WHITECPATH="$HOMEDIR/.Whitecoin"
VMNAME=$(hostname)
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Whitecoin path: $WHITECPATH"
echo "vmname: $VMNAME"
​
​
if [ "$1" = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen miniupnpc libminiupnpc-dev curl
cd /usr/local/src/ || exit
sudo git clone https://github.com/Whitecoin-org/Whitecoin whitecoin
cd whitecoin/src || exit
sudo make -f makefile.unix
​sudo strip whitecoind
sudo cp whitecoind /usr/bin/whitecoind
​
else
## Download Binaries
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen miniupnpc libminiupnpc-dev curl
cd /usr/local/src/ || exit
DOWNLOADFILE=$(curl -s https://api.github.com/repos/Whitecoin-org/Whitecoin/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/Whitecoin-org/Whitecoin/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget "$DOWNLOADFILE"
sudo unzip "$DOWNLOADNAME"
sudo chmod 755 whitecoind
sudo cp whitecoind /usr/bin/whitecoind
fi
​
# Create Client Directory
if [ ! -e "$WHITECPATH" ]
then
        su - "$AZUREUSER" -c "mkdir $WHITECPATH"
fi
​
# Download Blockchain
su - "$AZUREUSER" -c "cd $WHITECPATH; wget https://github.com/Whitecoin-org/xwc-blockchain/releases/download/latest/xwc-blockchain.zip"
su - "$AZUREUSER" -c "cd $WHITECPATH; unzip xwc-blockchain.zip"
​
# Create configuration File
su - "$AZUREUSER" -c "touch $WHITECPATH/Whitecoin.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser=$rpcu
rpcpassword=$rpcp
daemon=1" > "$WHITECPATH"/Whitecoin.conf
​
# Start Whitecoin Client
su - "$AZUREUSER" -c "whitecoind"
​
echo "completed Whitecoin install $$"
exit 0