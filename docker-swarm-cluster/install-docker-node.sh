#!/bin/bash
sudo wget -qO- https://experimental.docker.com/ > install-docker.sh
sudo chmod +x install-docker.sh
sudo ./install-docker.sh
sudo usermod -aG docker $1
sudo systemctl stop docker
sudo sed -i '/ExecStart/c\ExecStart=/usr/bin/docker -d -H 0.0.0.0:2375 -H fd://' /lib/systemd/system/docker.service
sudo systemctl start docker
