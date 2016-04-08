#!/bin/sh

sudo npm install azure-cli -g
sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv B58C58F4
sudo add-apt-repository 'deb http://download.aspanta.com/ubuntu trusty emercoin'
sudo apt-get -y update
sudo apt-get install emercoin emcssh emcweb
