#!/bin/bash
#wget https://gist.githubusercontent.com/sigwo/571296dcb54ff6d4109b/raw/31581df4713f979b4406486f3071291579745c90/install-INFX.sh;chmod +x install-INFX.sh;sh ./install-INFX.sh

# **************************************************************************
# Influx installer
# Influxd + Influx-qt + desktop icon
# Maintained by : sigwo
# **************************************************************************

# install dependencies
echo "*** Installing dependencies ***"
echo
#sudo apt-get -y update
#sudo apt-get -y upgrade
sudo apt-get install -y qt4-qmake libqt4-dev libminiupnpc-dev libdb++-dev libdb-dev libcrypto++-dev libqrencode-dev libboost-all-dev build-essential libboost-system-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libboost-filesystem-dev libboost-program-options-dev libboost-thread-dev libssl-dev libdb++-dev libssl-dev ufw git
echo
echo "*** Cloning INFX repo ***"
echo
git clone https://github.com/Coryvmcs1/Influxcoin.git infx
cd infx/src
make -f makefile.unix
#qmake
#make
sudo cp Influxd /usr/bin
echo
# create the firewall rules
echo
# uncomment the firewall lines and replace the port with the port required for either P2P or rpc port for local mining
echo "*** Create firewall rules ***"
sudo ufw allow 9239
sudo ufw allow 9238
sudo ufw allow 2210
sudo ufw allow 5950
sudo ufw allow 6050
sudo ufw allow 3000
sudo ufw enable
echo
# create config file and randomize the password
echo "*** Creating configuration file with randomized password ***"
echo
mkdir ~/.Influx
rm -f Influx.conf
echo "rpcuser=user
rpcpassword=$(cat /dev/urandom | tr -cd '[:alnum:]' | head -c32)
rpcallowip = 127.0.0.1
rpcport = 9239
server = 1
daemon = 1
listen = 1" >> ~/.Influx/Influx.conf
echo
echo
./Influxd
exit 0
