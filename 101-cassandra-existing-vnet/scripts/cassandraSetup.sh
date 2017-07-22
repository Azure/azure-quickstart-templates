#!/bin/bash

echo "test" >> $HOME/test

LOCAL_PRIVATE_IP=$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)
IS_SEED_NODE=1
HOST_IP=""
CASSANDRA_VERSION="latest"

if [ $1 = $LOCAL_PRIVATE_IP ]; then
    IS_SEED_NODE=0
    echo "host node detected"
else
    HOST_IP=$1
    echo "seed node detected"
fi

if [ -n "$2" ]; then
    CASSANDRA_VERSION=$2
fi

function install_cassandra() {
    if [ $IS_SEED_NODE = 0 ]; then
        docker run -d -e CASSANDRA_BROADCAST_ADDRESS="$LOCAL_PRIVATE_IP" -p 7000:7000 -p 9042:9042 cassandra:"$CASSANDRA_VERSION"
    else
        docker run -d -e CASSANDRA_BROADCAST_ADDRESS="$LOCAL_PRIVATE_IP" -e CASSANDRA_SEEDS="$HOST_IP" -p 7000:7000 -p 9042:9042 cassandra:"$CASSANDRA_VERSION"
    fi
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