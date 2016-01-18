#!/bin/bash

curl https://raw.githubusercontent.com/netkicorp/wns-api-server/master/DockerfileWithoutNamecoin -o "Dockerfile"

docker build -t netki-wns-api-server-no-nc .

docker run --name=netki-wns-api-server -i -p 80:5000 netki-wns-api-server-no-nc &
