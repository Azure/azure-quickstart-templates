#!/bin/bash

set -e

#################################################################
# Build Horizon from latest release                             #
# Install all necessary packages for building Horizon           #
#################################################################
sudo apt-get install -y software-properties-common
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y --force-yes oracle-java8-installer

cd /usr/local
sudo wget https://github.com/NeXTHorizon/hz-source/releases/download/hz-v5.4/hz-v5.4-node.zip
unzip hz-v5.4-node.zip

################################################################
# Configure to auto start at boot                              #
################################################################

file=/etc/init.d/Horizon
if [ ! -e "$file" ]
then
        printf '%s\n%s\n' '#!/bin/sh' 'sudo nohup ./usr/local/hz-v5.4-node/run.sh &' | sudo tee /etc/init.d/Horizon
        sudo chmod +x /etc/init.d/Horizon
        sudo update-rc.d Horizon default
fi

cd /usr/local/hz-v5.4-node
nohup ./run.sh &
echo "Horizon has been setup successfully and is running..."
exit 0
