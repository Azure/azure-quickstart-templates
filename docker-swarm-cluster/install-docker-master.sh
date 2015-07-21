#!/bin/bash
sudo wget -qO- https://experimental.docker.com/ > install-docker.sh
sudo chmod +x install-docker.sh
sudo ./install-docker.sh
sudo usermod -aG docker $1

sudo docker pull swarm

CLUSTERID="$(sudo docker run --rm swarm create)"

docker -H tcp://10.0.1.4:2375 run -d swarm join --addr="10.0.1.4:2375" token://$CLUSTERID
docker -H tcp://10.0.1.5:2375 run -d swarm join --addr="10.0.1.5:2375" token://$CLUSTERID
docker -H tcp://10.0.1.6:2375 run -d swarm join --addr="10.0.1.6:2375" token://$CLUSTERID