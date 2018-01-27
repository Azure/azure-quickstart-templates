#!/bin/bash

apt-get update

wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip?_ga=2.228206621.1801000149.1512425211-1345627201.1504718143

apt-get install unzip

unzip terraform.zip

mv terraform /usr/local/bin

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893

apt-get install apt-transport-https

apt-get update && sudo apt-get install azure-cli
