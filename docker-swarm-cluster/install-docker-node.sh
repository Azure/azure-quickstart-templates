#/bin/bash
sudo wget -qO- https://experimental.docker.com/ | sh
sudo usermod -aG docker $1
sudo systemctl stop docker
sudo echo 'DOCKER_OPTS="-H 0.0.0.0:2375 -d"' > /etc/default/docker
sudo systemctl stop docker
