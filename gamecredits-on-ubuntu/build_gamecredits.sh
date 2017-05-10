#!/bin/bash
set -x

echo "initializing GameCredits installation"

date
ps axjf

AZUREUSER=$2
HOMEDIR="/home/$AZUREUSER"
GAMECREDITSPATH="$HOMEDIR/.gamecredits"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "User gamecredits path: $GAMECREDITSPATH"
echo "vmname: $VMNAME"


if [ $1 = 'From_Source' ]; then
## Compile from Source ##
sudo apt-get update

NPROC=$(nproc)
echo "nproc: $NPROC"

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
# Installation from binaries #
cd /usr/local/src/

DOWNLOADFILE=$(curl -s https://api.github.com/repos/gamecredits-project/GameCredits/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/gamecredits-project/GameCredits/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)

sudo wget $DOWNLOADFILE
sudo unzip $DOWNLOADNAME
sudo cp gamecreditsd /usr/bin/gamecreditsd
sudo cp gamecreditsd /usr/bin/gamecredits-cli

fi

# Configure to auto start at boot #

file=$HOME/.gamecredits 
if [ ! -e "$file" ]
then
	sudo mkdir $HOME/.gamecredits
fi

# Download GameCredits Gaming Blockchain
su - $AZUREUSER -c "cd $GAMECREDITSPATH; wget https://github.com/gamecredits-project/gamecredits-blockchain/releases/download/latest/gamecredits-blockchain.zip"
su - $AZUREUSER -c "cd $GAMECREDITSPATH; unzip gamecredits-blockchain.zip"

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
