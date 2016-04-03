#!/bin/bash

set -e

date
ps axjf

sudo apt-get update
NPROC=$(nproc)
echo "nproc: $NPROC"
sudo apt-get install -y build-essential libboost-all-dev libcurl4-openssl-dev git qt-sdk libminiupnpc-dev
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

cd /usr/local
file=/usr/local/btcd
if [ ! -e "$file" ]
then
        sudo git clone https://github.com/laowais/bitcoindark.git btcd
fi

cd /usr/local/btcd/src
file=/usr/local/btcd/src/BitcoinDarkd
if [ ! -e "$file" ]
then
        mkdir obj
        cp -r zerocoin/ obj/
        sudo make -j $NPROC -f makefile.unix
fi
sudo cp /usr/local/btcd/src/BitcoinDarkd /usr/bin/bitcoindarkd
file=$HOME/.BitcoinDark
if [ ! -e "$file" ]
then
        sudo mkdir $HOME/.BitcoinDark
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=u' 'rpcpassword=p' 'addnode=explorebtcd.info' | sudo tee $HOME/.BitcoinDark/.BitcoinDark.conf

/usr/bin/bitcoindarkd
exit 0
