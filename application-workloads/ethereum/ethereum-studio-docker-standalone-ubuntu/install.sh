#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get -y install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

apt-get -y install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get -y install docker-ce

docker run -d --env MODE=standalone -p 80:8181 -p 8555:8555 -p 8080:8080 ethercamp/ide