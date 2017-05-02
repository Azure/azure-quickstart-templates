#!/bin/sh

. /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
wget -qO- https://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
sudo apt-get -y update
sudo apt-get -y install rethinkdb

rethinkdb --bind all --daemon

sudo apt-get -y install make
sudo apt-get -y install g++ python3-dev libffi-dev
sudo apt-get -y install python3-setuptools

export LANG="en_US.UTF-8"

sudo easy_install3 pip
sudo pip3 install --upgrade pip wheel setuptools

sudo pip3 install bigchaindb
