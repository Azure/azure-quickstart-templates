#!/bin/bash 

echo "deb http://download.rethinkdb.com/apt trusty main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
wget -qO- https://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
sudo apt-get -y update
sudo apt-get -y install rethinkdb

sudo cp /etc/rethinkdb/default.conf.sample /etc/rethinkdb/instances.d/instance1.conf

sudo /etc/init.d/rethinkdb restart

sudo apt-get -y install g++ python3-dev libffi-dev

sudo apt-get -y install python3-setuptools
sudo easy_install3 pip
sudo pip3 install --upgrade pip wheel setuptools

sudo pip install bigchaindb
