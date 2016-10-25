#!/bin/bash 

# prereqs
sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates

# generate GPG key
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# update apt-get for docker
sudo echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' | sudo tee --append /etc/apt/sources.list.d/docker.list
sudo apt-get -y update
sudo apt-get -y purge lxc-docker
sudo apt-cache policy docker-engine

# install extra kernel packages (if missing)
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual

# install docker
sudo apt-get -y install docker-engine

# configure docker to start on boot
sudo systemctl enable docker
sudo service docker start

# now the good stuff
sudo mkdir -p /var/lib/chain/postgresql/data /var/log/chain/
sudo docker run -d -p 1999:1999 -v /var/lib/chain/postgresql/data:/var/lib/postgresql/data -v /var/log/chain/:/var/log/chain --name chain --restart always chaincore/developer
