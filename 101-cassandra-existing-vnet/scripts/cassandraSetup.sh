#!/bin/bash

echo "test" >> $HOME/test
echo "$1"
echo "$2"

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
    echo "1"
    CASSANDRA_VERSION=$2
    echo "2"
fi

echo "3"

function install_cassandra() {
    echo "4"
    if [ $IS_SEED_NODE = 0 ]; then
        echo "5"
        docker run -d -e CASSANDRA_BROADCAST_ADDRESS="$LOCAL_PRIVATE_IP" -p 7000:7000 -p 9042:9042 cassandra:"$CASSANDRA_VERSION"
        "echo 6"
    else
        echo "7"
        docker run -d -e CASSANDRA_BROADCAST_ADDRESS="$LOCAL_PRIVATE_IP" -e CASSANDRA_SEEDS="$HOST_IP" -p 7000:7000 -p 9042:9042 cassandra:"$CASSANDRA_VERSION"
        echo "8"
    fi
}

function install_dependencies() {
    echo "8"
    apt-get update
    "echo 9"
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    echo "10"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo "11"
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    echo "12"
    apt-get update
    echo "14"
    apt-get install -y docker-ce
    echo "15"
}

install_dependencies
install_cassandra