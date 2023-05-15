#!/bin/bash -v
sudo apt-get update -y
sudo apt-get -y install tcpreplay
sudo apt-get install -y docker.io
sudo docker run -v /:/host -v /var/run/docker.sock:/var/run/docker.sock --privileged --name cloudlens-agent -d --restart=on-failure --net=host ixiacom/cloudlens-agent --accept_eula yes --apikey $1 --custom_tags Name="CloudLens Quick Start Source Instance"
