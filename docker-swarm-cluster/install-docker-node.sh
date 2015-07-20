#/bin/bash
wget -qO- https://experimental.docker.com/ | sh
usermod -aG docker $1
systemctl stop docker
echo 'DOCKER_OPTS="-H 0.0.0.0:2375 -d"' > /etc/default/docker
systemctl stop docker
