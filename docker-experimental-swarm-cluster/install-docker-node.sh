#!/bin/bash
sudo wget -qO- https://experimental.docker.com/ > install-docker.sh
sudo chmod +x install-docker.sh
sudo ./install-docker.sh
sudo usermod -aG docker $1
sudo systemctl stop docker
sudo sed -i '/DOCKER_OPTS/c\DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock"' /etc/default/docker
sudo systemctl daemon-reload
sudo systemctl start docker
