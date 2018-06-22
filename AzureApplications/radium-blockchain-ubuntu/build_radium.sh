#!/bin/bash

set -e 
date
ps axjf
NPROC=$(nproc)
echo "nproc: $NPROC"

#################################################################
# Update Ubuntu and install prerequisites for running Radium #
#################################################################

time apt-get update
time apt-get install -y ntp wget git miniupnpc build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libtool autotools-dev autoconf pkg-config

#################################################################
# Build config file                                             #
#################################################################

file=$HOME/.Radium
if [ ! -e "$file" ]
then
sudo mkdir $HOME/.Radium
fi

sudo printf 'rpcuser=%s\n' $2  >> $HOME/.Radium/Radium.conf
sudo printf 'rpcpassword=%s\n' $3 >> $HOME/.Radium/Radium.conf
sudo printf 'rpcport=%s\n' $4 >> $HOME/.Radium/Radium.conf
sudo printf 'rpcallowip=%s\n' $5 >> $HOME/.Radium/Radium.conf
sudo printf 'server=1' >> $HOME/.Radium/Radium.conf


if [ $1 = 'From_Source' ]; then
#################################################################
# Build Radium from source                                      #
#################################################################

# git clone source
cd /usr/local
time git clone https://github.com/tm2013/Radium.git
chmod -R 777 /usr/local/Radium/

# Build  source                                

cd /usr/local/Radium/src 
make -f makefile.unix USE_UPNP=-
cp /usr/local/Radium/src/Radiumd /usr/bin/Radiumd

else
#################################################################
# Install Radium from Binary                                    #
#################################################################

cd /usr/local
DOWNLOADFILE=$(curl -s https://api.github.com/repos/JJ12880/Radium/releases | grep browser_download_url | grep linux64 | head -n 1 | cut -d '"' -f 4)
DOWNLOADNAME=$(curl -s https://api.github.com/repos/JJ12880/Radium/releases | grep name | grep linux64 | head -n 1 | cut -d '"' -f 4)
DIRNAME=$(echo $DOWNLOADNAME | sed 's/.tgz//')
wget $DOWNLOADFILE
tar zxf $DOWNLOADNAME
rm $DOWNLOADNAME
cp Radiumd /usr/bin/Radiumd
chmod 777 /usr/bin/Radiumd
rm Radiumd

fi


################################################################
# Configure Radium node to auto start at boot       #
#################################################################

printf '%s\n%s\n' '#!/bin/sh' '/usr/bin/Radiumd --datadir/.Radiumd'>> /etc/init.d/radium
chmod +x /etc/init.d/radium
update-rc.d radium defaults
/usr/bin/Radiumd  --datadir/.Radiumd & exit 0
