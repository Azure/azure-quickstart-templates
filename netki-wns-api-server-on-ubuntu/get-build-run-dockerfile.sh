#!/bin/bash

curl -O https://raw.githubusercontent.com/netkicorp/wns-api-server/master/DockerfileWithoutNamecoin

mv DockerfileWithoutNamecoin Dockerfile

docker build -t netki-wns-api-server-no-nc .

docker run --name=netki-wns-api-server -i -p 80:5000 netki-wns-api-server-no-nc
