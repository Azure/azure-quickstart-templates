#!/bin/sh
sudo apt-get update
sudo apt-get install -y git

git clone https://github.com/Azure/bosh.git
cd bosh/deploy_for_azure
./install.sh