#!/bin/bash
echo "start"
read -p "what's your username of VM: " USER
read -p "what's your password: " PSW
echo $PSW | sudo -S apt update
echo "install Docker"

#Install Docker
yes Y | sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "1"
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
echo "2"
sudo apt update
echo "3"
yes Y | apt-cache policy docker-ce
echo "4"
yes Y | sudo apt install docker-ce
echo "5"

echo "Enable Docker without Sudo"
#Enable Docker without Sudo (for user 'openadmin')
echo $PSW | sudo -S usermod -aG docker $USER
su - $USER -c docker --version

echo "docker compose"
yes Y | sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
yes Y | sudo chmod +x /usr/local/bin/docker-compose

echo "install tutor"
#install tutor

sudo curl -L "https://github.com/overhangio/tutor/releases/download/v12.0.2/tutor-$(uname -s)_$(uname -m)" -o /usr/local/bin/tutor
sudo chmod -R 0777 /usr/local/bin/tutor

echo "deploy tutor"
#configure tutor
tutor local quickstart

echo "finish"


