#!/bin/bash
touch /etc/apt/sources.list
sudo apt-get -y upgrade
sudo apt-get -y update

#install gnome desktop
sudo apt-get install ubuntu-gnome-desktop -y

#install xrdp
sudo apt-get install xrdp -y

# change access from root only to all users
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config

#install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#install VSCode
sudo snap install --classic code

#start remote desktop session
sudo service xrdp restart
