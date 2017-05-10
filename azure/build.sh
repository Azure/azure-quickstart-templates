#!/bin/bash
wget https://github.com/wavesplatform/Waves/releases/download/v0.0.1/waves-testnet-0.0.1.zip
sudo apt-get update
sudo apt-get install -y software-properties-common unzip
sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y --force-yes oracle-java8-installer
unzip waves-testnet-0.0.1.zip
mv waves-testnet-0.0.1 waves
cd waves
#rm waves-testnet.json
sudo dpkg -i waves_0.0.1_all.deb
waves waves-testnet.json
cat <<< "sigwotesting"
