#!/bin/bash
set -x

echo "Initializing GameCredits Gaming Blockchain installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
GAMECREDITSPATH="$HOMEDIR/.gamecredits"
VMNAME=$(hostname)
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User Gamecredits path: $GAMECREDITSPATH"
echo "vmname: $VMNAME"


if [ "$1" = 'From_Source' ]; then
## Compile from Source
sudo apt-get update
sudo apt-get -y install git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev unzip pwgen
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local/src/ || exit
sudo git clone https://github.com/gamecredits-project/GameCredits.git 
cd GameCredits/src || exit

sudo ./autogen.sh
sudo ./configure
sudo make -j$NPROC
sudo strip gamecreditsd
sudo cp gamecreditsd /usr/bin/gamecreditsd

else    
## Download Binaries
sudo apt-get update
sudo apt-get -y install git wget build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev libminiupnpc-dev libzmq3-dev unzip pwgen
cd /usr/local/src/ || exit
DOWNLOADFILE=$(curl -s https://api.github.com/repos/gamecredits-project/GameCredits/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/gamecredits-project/GameCredits/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
sudo wget "$DOWNLOADFILE"
sudo unzip "$DOWNLOADNAME"
sudo chmod 755 gamecreditsd
sudo chmod 755 gamecredits-cli
sudo cp gamecreditsd /usr/bin/gamecreditsd
sudo cp gamecredits-cli /usr/bin/gamecredits-cli
fi

# Create Client Directory
if [ ! -e "$GAMECREDITSPATH" ]
then
        su - "$AZUREUSER" -c "mkdir $GAMECREDITSPATH"
fi

# Download GameCredits Blockchain
su - "$AZUREUSER" -c "cd $GAMECREDITSPATH; wget https://github.com/gamers-coin/gamecredits-blockchain/releases/download/v1.0/blockchain.zip"
su - "$AZUREUSER" -c "cd $GAMECREDITSPATH; unzip blockchain.zip"

# Create configuration File
su - "$AZUREUSER" -c "touch $GAMECREDITSPATH/gamecredits.conf"
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser=$rpcu
rpcpassword=$rpcp
daemon=1" > "$GAMECREDITSPATH"/gamecredits.conf

# Start GameCredits Client
su - "$AZUREUSER" -c "gamecreditsd"

echo "Gamecredits Blockchain has been setup successfully and is running... $$"
exit 0
