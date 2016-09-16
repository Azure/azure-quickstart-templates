#!/bin/bash

sudo apt-get update && sudo apt-get install -y wget unzip

sudo mkdir -p /opt/consul/data
cd /opt/consul
sudo wget https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip
sudo unzip consul_0.6.3_linux_amd64.zip
sudo chmod 755 consul
cd /opt/consul
sudo nohup ./consul agent -server -bind 0.0.0.0 -client 0.0.0.0 -data-dir="/opt/consul/data" -bootstrap-expect 3 -atlas=$1 -atlas-join -atlas-token="$2" &
