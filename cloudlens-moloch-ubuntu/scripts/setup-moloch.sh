#!/bin/bash -v
sudo apt-get update
sudo apt-get install -y docker.io
sudo docker run -v /:/host -v /var/run/docker.sock:/var/run/docker.sock --privileged --name cloudlens-agent -d --restart=on-failure --net=host ixiacom/cloudlens-agent --accept_eula yes --apikey $1 --custom_tags Name="CloudLens Quick Start Tool Instance"
sudo docker run -d --name es elasticsearch:5.2.2-alpine
sudo docker run --name moloch -p 8005:8005 -d --link es:elasticsearch sksrinivasan27/moloch_cloudlens
