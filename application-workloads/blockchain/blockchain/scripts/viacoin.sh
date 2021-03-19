#!/bin/bash
set -e
date
ps axjf
#Build Viacoin from source
NPROC=$(nproc)
echo "nproc: $NPROC"
# install all required dependencies for running Via
sudo sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install build-essential libtool autotools-dev autoconf pkg-config libssl-dev libboost-all-dev libdb4.8-dev libdb4.8++-dev libminiupnpc-dev git automake -y

cd /usr/local
file=/usr/local/viacoin
if [ ! -e "$file" ]; then
    sudo git clone https://github.com/viacoin/viacoin.git viacoin
fi
 
cd /usr/local/viacoin
file=/usr/local/viacoin/src/viacoind
if [ ! -e "$file" ]; then
        ./autogen.sh;./configure --with-gui=no --enable-tests=no;make;sudo make install
fi

sudo cp -f /usr/local/viacoin/src/viacoind /usr/bin/viacoind

#configure autostart at boot
file=$HOME/.viacoin
if [ ! -e "$file" ]; then
      sudo mkdir $HOME/.viacoin
fi
printf '%s\n%s\n%s\n%s\n' 'daemon=1' 'server=1' 'rpcuser=viacoinrpc' 'rpcpassword=p' | sudo tee $HOME/.viacoin/viacoin.conf
file=/etc/init.d/viacoin
if [ ! -e "$file" ]; then
    printf '%s\n%s\n' '#!/bin/sh' 'sudo viacoind' | sudo tee /etc/init.d/viacoin
    sudo chmod +x /etc/init.d/viacoin
    sudo update-rc.d viacoin defaults
fi
/usr/bin/viacoind
echo "Viacoin has been setup succesfully and is running..."
exit 0
