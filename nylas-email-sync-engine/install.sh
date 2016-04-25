#!/bin/bash

# install git
sudo apt-get install -y git

# clone the sync engine repo
git clone https://github.com/singhkay/sync-engine.git

# kick off the setup script
cd sync-engine/
chmod +x setup.sh
sudo ./setup.sh

# start your engines!
nohup bin/inbox-start &

