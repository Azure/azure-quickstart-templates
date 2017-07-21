#!/bin/bash

function install_cassandra() {
    localPrivateIP=$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)
    docker run -d -e CASSANDRA_BROADCAST_ADDRESS="$localPrivateIP" -p 7000:7000 -p 9042:9042 cassandra:latest
}

function install_dependencies() {
    apt-get update

    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    apt-get update
    apt-get install -y docker-ce
}

install_dependencies
install_cassandra