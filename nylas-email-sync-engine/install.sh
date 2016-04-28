#!/bin/bash

# update os
apt-get update

# install git
apt-get install -y git

# clone the sync engine repo
cd ~
cd /usr/local
git clone https://github.com/singhkay/sync-engine.git
cd /usr/local/sync-engine/

# kick off the setup script
chmod +x ./setup.sh
sudo ./setup.sh
