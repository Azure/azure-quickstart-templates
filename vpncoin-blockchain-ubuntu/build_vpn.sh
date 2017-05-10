#!/bin/bash
set -e
date
ps axjf
sudo apt-get update
NPROC=$(nproc)
echo "nproc: $NPROC"
sudo apt-get install -y build-essential libboost-all-dev libcurl4-openssl-dev git qt-sdk libminiupnpc-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

cd /usr/local
file=/usr/local/vpncoin
if [ ! -e "$file" ]
then
        sudo git clone https://github.com/Bit-Net/VpnCoin.git vpncoin
fi

cd /usr/local/vpncoin/src
file=/usr/local/vpncoin/src/vpncoind
if [ ! -e "$file" ]
then
        sudo make -j$NPROC -f makefile.unix
fi

sudo cp /usr/local/vpncoin/src/vpncoind /usr/bin/vpncoind

file=$HOME/.vpncoin
if [ ! -e "$file" ]
then
        sudo mkdir $HOME/.vpncoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' | sudo tee $HOME/.vpncoin/vpncoin.conf
file=/etc/init.d/vpncoin
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo vpncoind' | sudo tee /etc/init.d/vpncoin
        sudo chmod +x /etc/init.d/vpncoin
        sudo update-rc.d vpncoin defaults
fi

/usr/bin/vpncoind
echo "VPNCoin has been setup successfully and is running..."
exit 0
