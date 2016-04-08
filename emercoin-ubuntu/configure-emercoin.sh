#!/bin/sh

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv B58C58F4
sudo add-apt-repository 'deb http://download.aspanta.com/ubuntu trusty emercoin'
sudo apt-get -y update
sudo apt-get install emercoin emcssh emcweb
sudo emcweb-user "$1" "$2"
