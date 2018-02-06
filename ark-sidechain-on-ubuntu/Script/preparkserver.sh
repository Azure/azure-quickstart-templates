#!/bin/bash
sudo apt-get -y update && sudo apt-get -y install libpq-dev nodejs npm build-essential libtool autoconf automake zip unzip htop nmon iftop pkg-config libcairo2-dev libgif-dev jq

# to be remedied with a --install-deps flag by developers
sudo npm install grunt-cli
sudo npm install node-sass
sudo npm install forever
sudo npm install angular-cli

sudo apt-get -y install postgresql postgresql-contrib
