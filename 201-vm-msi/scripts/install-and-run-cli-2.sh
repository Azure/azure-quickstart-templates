#!/bin/bash

while getopts ":i:a:c:r:" opt; do
  case $opt in
    i) docker_image="$OPTARG"
    ;;
    a) storage_account="$OPTARG"
    ;;
    c) container_name="$OPTARG"
    ;;
    r) resource_group="$OPTARG"
    ;;
    p) port="$OPTARG"
    ;;
    t) script_file="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z $docker_image ]; then
    docker_image="mcr.microsoft.com/azure-cli"
fi

if [ -z $script_file ]; then
    script_file="writeblob.sh"
fi

for var in storage_account resource_group
do

    if [ -z ${!var} ]; then
        echo "Argument $var is not set" >&2
        exit 1
    fi

done

# Install Docker and then run docker image with cli.

sudo apt-get update
sudo apt-get install -y docker.io
sudo docker run -d -v $PWD:/scripts \
-e STORAGE_ACCOUNT=${storage_account} \
-e CONTAINER_NAME=${container_name} \
-e RESOURCE_GROUP=${resource_group} \
-e PORT=${PORT} \
${docker_image} "/scripts/${script_file}"