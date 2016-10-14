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

# Fill in the configuration

REGUSER=`echo $KEY | awk -F: '{ print $1; }'`
REGPASSWD=`echo $KEY | awk -F: '{ print $2; }'`

sed -i "s|REGISTRY_USERNAME=.*|REGISTRY_USERNAME=$REGUSER|" conf.sh
sed -i "s|REGISTRY_PASSWORD=.*|REGISTRY_PASSWORD=$REGPASSWD|" conf.sh
sed -i "s|REGISTRY_EMAIL=.*|REGISTRY_EMAIL=$EMAIL|" conf.sh

sed -i "s|API_URL=.*|API_URL=http://$DNS|" conf.sh
sed -i "s|APP_URL=.*|APP_URL=http://$DNS|" conf.sh

sed -i "s|API_SUPER_USER=.*|API_SUPER_USER=$EMAIL|" conf.sh
sed -i "s|API_SUPER_PASSWD=.*|API_SUPER_PASSWD=$PASSWORD|" conf.sh

# Store the data on the data disk

sed -i "s|data/cassandra|/data/cassandra|" volumes/cassandra
sed -i "s|data/elasticsearch|/data/elasticsearch|" volumes/elasticsearch
sed -i "s|data/postgresql|/data/postgresql|" volumes/postgresql

mkdir -p /data/cassandra /data/elasticsearch /data/postgresql

./pull.sh
./run.sh

# Start CoScale on reboot

cat << EOF > /etc/systemd/system/coscale.service
[Unit]
Description=CoScale
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=/home/cs/cop
ExecStartPre=/home/cs/cop/stop.sh
ExecStart=/home/cs/cop/run.sh

[Install]
WantedBy=default.target
EOF

systemctl enable coscale.service
