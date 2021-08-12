#!/bin/bash
echo "start"


sudo apt update
echo "install Docker"

#Install Docker
yes Y | sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
yes Y | apt-cache policy docker-ce
yes Y | sudo apt install docker-ce

echo "docker compose"
yes Y | sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
yes Y | sudo chmod +x /usr/local/bin/docker-compose

echo "Enable Docker without Sudo"
#Enable Docker without Sudo (for user 'openadmin')
sudo usermod -aG docker openadmin

yes Y | sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
yes Y | sudo chmod +x /usr/local/bin/docker-compose

echo "install tutor"
#install tutor

sudo curl -L "https://github.com/overhangio/tutor/releases/download/v12.0.2/tutor-$(uname -s)_$(uname -m)" -o /usr/local/bin/tutor
sudo chmod 0755 /usr/local/bin/tutor
