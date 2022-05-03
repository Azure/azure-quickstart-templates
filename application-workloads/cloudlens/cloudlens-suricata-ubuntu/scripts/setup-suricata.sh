#!/bin/bash -v
sudo apt-get update
sudo apt-get install git -y
sudo apt-get install python -y
sudo apt-get install python-setuptools -y
sudo apt-get install python-openssl -y
sudo apt-get install docker-compose -y
sudo apt-get install -y docker.io
git clone https://github.com/StamusNetworks/Amsterdam.git
cd Amsterdam
sudo python setup.py install
sudo docker run -v /:/host -v /var/run/docker.sock:/var/run/docker.sock --privileged --name cloudlens-agent -d --restart=on-failure --net=host ixiacom/cloudlens-agent --accept_eula yes --apikey $1 --custom_tags Name="CloudLens Quick Start Tool Instance"
sudo amsterdam -d ams -i cloudlens0 setup
screen -dmS start_suricata sudo amsterdam -d ams start
