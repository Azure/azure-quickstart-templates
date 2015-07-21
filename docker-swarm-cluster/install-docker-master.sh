#!/bin/bash
sudo wget -qO- https://experimental.docker.com/ > install-docker.sh
sudo chmod +x install-docker.sh
sudo ./install-docker.sh
sudo usermod -aG docker $1

sudo docker pull swarm

CLUSTERID="$(sudo docker run --rm swarm create)"

docker run -H tcp://10.0.1.4 -d swarm join --addr="10.0.1.4" token://$CLUSTERID
docker run -H tcp://10.0.1.5 -d swarm join --addr="10.0.1.5" token://$CLUSTERID
docker run -H tcp://10.0.1.6 -d swarm join --addr="10.0.1.6" token://$CLUSTERID