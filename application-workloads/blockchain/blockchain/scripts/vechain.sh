#!/bin/bash

#################################################################
# VeChain Deployment script will configure thor node from the source #
#################################################################

#################################################################
# Clear the console and read network details from the arguments #
#################################################################
clear
network=$1

#################################################################
# VeChain Deployment script starts here #
#################################################################
echo "This script will setup a VeChain node."
echo "---"

#################################################################
# Set environment paths #
#################################################################
echo "Setting up environment variables"
cd ~
sudo touch ${HOME}/.profile
sudo echo "export PATH=$PATH:/usr/local/go/bin" >> ${HOME}/.profile
sudo echo "export GOPATH=$HOME/go" >> ${HOME}/.profile
export PATH=$PATH:/usr/local/go/bin
export GOPATH=${HOME}/go
export network=${network}
sudo mkdir -p $GOPATH/src
echo "---"

#################################################################
# Updating and upgrading linux environment   #
#################################################################
echo "Performing a general system update (this might take a while)..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y upgrade > /dev/null 2>&1
sudo apt-get -y dist-upgrade > /dev/null 2>&1
echo "---"

#################################################################
# Installing pre-requisites for VeChain deployment   #
#################################################################
echo "Installing prerequisites..."
sudo apt-get -y install build-essential libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev git > /dev/null 2>&1
echo "---"

#################################################################
# Downloading and installing Go dependency #
#################################################################
echo "Installing go..."
cd ~
sudo wget https://dl.google.com/go/go1.14.linux-amd64.tar.gz > /dev/null 2>&1
sudo tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz > /dev/null 2>&1
sudo chmod +x /usr/local/go/bin/go > /dev/null 2>&1
sudo rm go1.14.linux-amd64.tar.gz > /dev/null 2>&1
echo "---"

#################################################################
# Downloading and installing Dep dependency   #
#################################################################
echo "Installing dep..."
cd /usr/local/bin/
sudo wget https://github.com/golang/dep/releases/download/v0.5.4/dep-linux-amd64 > /dev/null 2>&1
sudo ln -s dep-linux-amd64 dep > /dev/null 2>&1
sudo chmod +x /usr/local/bin/* > /dev/null 2>&1
echo "---"

#################################################################
# Cloning VeChain git repositor and build the complete suite  #
#################################################################
echo "Installing and configuring VeChain..."
sudo git clone https://github.com/vechain/thor.git $GOPATH/src/VeChain/thor > /dev/null 2>&1
cd $GOPATH/src/VeChain/thor
sudo chmod -R 777 ${HOME}/go
make dep > /dev/null 2>&1
make all > /dev/null 2>&1
echo "---"

################################################################
# Configure to auto start thor node at boot					    #
################################################################
file=/etc/init.d/vechain
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' '$GOPATH/src/VeChain/thor/bin/thor -network main' | sudo tee /etc/init.d/vechain
	sudo chmod +x /etc/init.d/vechain
	sudo update-rc.d vechain defaults	
fi

################################################################
# Start thor node					    #
################################################################
sudo $GOPATH/src/VeChain/thor/bin/thor -network $network > /dev/null 2>&1
echo "VeChain thor node has been setup successfully and is running..."
exit 0