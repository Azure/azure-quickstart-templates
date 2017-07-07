#!/bin/bash
userPassword=$1

#download the packages
cd /tmp
wget -c http://swupdate.openvpn.org/as/openvpn-as-2.1.9-Ubuntu16.amd_64.deb
#sudo apt-get update

#install the software
sudo dpkg -i openvpn-as-2.1.9-Ubuntu16.amd_64.deb
#sudo apt-get -y install openvpn-as

#update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd
