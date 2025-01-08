#!/bin/bash -v
sudo apt-get update -y
sudo apt-get -y install tcpreplay
sudo apt-get install -y docker.io
sudo ip link add name CloudlensReplay type dummy
sudo ifconfig CloudlensReplay up
wget --tries=50 https://s3.amazonaws.com/cloudlens-automation/quickstart/malware.pcap
sudo docker run -v /:/host -v /var/run/docker.sock:/var/run/docker.sock --privileged --name cloudlens-agent -d --restart=on-failure --net=host ixiacom/cloudlens-agent --accept_eula yes --listen CloudlensReplay --apikey $1 --custom_tags Name="CloudLens Quick Start Source Instance"
screen -dmS gen_traffic sudo tcpreplay --loop=0 --intf1=CloudlensReplay /var/lib/waagent/custom-script/download/0/malware.pcap
