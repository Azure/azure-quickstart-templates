#!/bin/bash

KEY=$1
EMAIL=$2
PASSWORD=$3
DNS=$4

## Initialize the data disk

parted -s /dev/sdc mklabel msdos
parted -s /dev/sdc mkpart primary ext4 0\% 100\%
mkfs.ext4 /dev/sdc1
mkdir /data/
mount /dev/sdc1 /data/
echo "/dev/sdc1    /data/    ext4    defaults 0 0" >> /etc/fstab

## Install Docker

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
bash -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list'
apt-get update
apt-get install -y docker-engine
usermod -aG docker cs

## Install CoScale

cd /home/cs

URL=`curl -s https://api.github.com/repos/fryckbos/cop/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4`
wget $URL
mkdir -p cop && cd cop && tar xzf ../cop.tgz

cd azure
./install-dev.sh $KEY $EMAIL $PASSWORD $DNS
