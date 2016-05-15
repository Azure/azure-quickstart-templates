#!/bin/bash
set -x

echo "Gapcoin installation"

date
ps axjf

AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

cd $HOMEDIR
#################################################################
# Update Ubuntu and install prerequisites for running Gapcoin  #
#################################################################
sudo apt-get update

#################################################################
# Install all necessary packages for building Gapcoin         #
#################################################################
sudo apt-get -y install git unzip pwgen transmission libboost-all-dev
sudo wget https://raw.githubusercontent.com/HyperSpaceChain/azure-blockchain-projects/master/baas-artifacts/linux-gapcoin/bulid_gap.sh
sudo mkdir .gapcoin
cd .gapcoin
sudo wget https://github.com/Sunium/gapcoin/releases/download/linux-wallet-x64%26blocks-bootstrap/gapcoin-cli
sudo wget https://github.com/Sunium/gapcoin/releases/download/linux-wallet-x64%26blocks-bootstrap/gapcoin-qt
sudo wget https://github.com/Sunium/gapcoin/releases/download/linux-wallet-x64%26blocks-bootstrap/gapcoind
sudo wget https://github.com/Sunium/gapcoin/releases/download/linux-wallet-x64%26blocks-bootstrap/md5sum.txt
################################################################
# Configure		                       #
################################################################
sudo touch ./gapcoin.conf
rpcu=$(pwgen -ncsB 35 1)
rpcp=$(pwgen -ncsB 75 1)
echo "rpcuser="$rpcu"
rpcpassword="$rpcp"
daemon=1" > ./gapcoin.conf
sudo cp gapcoind /usr/bin/gapcoind
sudo chmod +x /usr/bin/gapcoind
################################################################
# BootStrap to synchronize your node within 20 minutes        #
################################################################
#mkdir blocks
#cd blocks
#wget https://github.com/Sunium/gapcoin/releases/download/linux-wallet-x64%26blocks-bootstrap/GapcoinBlocks.zip
#unzip GapcoinBlocks.zip
################################################################
# start at boot		                       #
################################################################
sudo gapcoind

echo "gapcoin has been setup successfully and is running"
exit 0