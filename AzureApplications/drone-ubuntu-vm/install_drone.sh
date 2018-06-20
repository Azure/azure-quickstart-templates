#!/bin/bash

# set local variables
GITHUB_CLIENT=$1
GITHUB_SECRET=$2

# retrieve latest package updates
apt-get update

# install dependencies
apt-get install -y linux-image-extra-$(uname -r) libsqlite3-dev

# configure Docker for AUFS
sed -i 's/^#DOCKER_OPTS.*/DOCKER_OPTS="-s aufs"/' /etc/default/docker

# retrieve and install Drone package
wget downloads.drone.io/master/drone.deb
dpkg --install drone.deb
rm -f drone.deb

# modify drone.toml
echo -e "\n\n[github]" >> /etc/drone/drone.toml
echo "client=\"$GITHUB_CLIENT\"" >> /etc/drone/drone.toml
echo "secret=\"$GITHUB_SECRET\"" >> /etc/drone/drone.toml
echo "open=false" >> /etc/drone/drone.toml
echo "\n\n[worker]" >> /etc/drone/drone.toml
echo "nodes=[" >> /etc/drone/drone.toml
echo "  \"unix:///var/run/docker.sock\"," >> /etc/drone/drone.toml
echo "  \"unix:///var/run/docker.sock\"" >> /etc/drone/drone.toml
echo "]" >> /etc/drone/drone.toml

# restart
reboot
