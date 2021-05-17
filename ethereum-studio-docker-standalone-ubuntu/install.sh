#!/bin/bash

sudo apt-get -y update
sudo apt-get install -y docker.io

sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

docker pull ethercamp/ide

docker run ethercamp/ide --env MODE=standalone -p 80:8181 -p 8555:8555 -p 8080:8080