#!/bin/bash
sudo wget -qO- https://experimental.docker.com/ > install-docker.sh
sudo chmod +x install-docker.sh
sudo ./install-docker.sh
sudo usermod -aG docker $1

sudo docker pull swarm

sudo docker run --rm swarm create > clusterId.txt

CLUSTERID=$(cat clusterId.txt)

docker -H tcp://10.0.1.4:2375 run -d swarm join --addr="10.0.1.4:2375" token://$CLUSTERID
docker -H tcp://10.0.1.5:2375 run -d swarm join --addr="10.0.1.5:2375" token://$CLUSTERID
docker -H tcp://10.0.1.6:2375 run -d swarm join --addr="10.0.1.6:2375" token://$CLUSTERID

docker run -d -p 5005:2375 swarm manage token://$CLUSTERID
