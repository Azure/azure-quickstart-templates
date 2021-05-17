#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# retrieve latest package updates
apt-get update
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install -y docker-ce

# install dependencies
apt-get install -y linux-image-extra-$(uname -r) libsqlite3-dev

# configure Docker for AUFS
sed -i 's/^#DOCKER_OPTS.*/DOCKER_OPTS="-s aufs"/' /etc/default/docker

docker run -d --env MODE=standalone -p 80:8181 -p 8555:8555 -p 8080:8080 ethercamp/ide