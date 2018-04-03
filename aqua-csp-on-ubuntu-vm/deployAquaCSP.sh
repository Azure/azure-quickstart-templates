#!/bin/bash

echo "step start: globals"
ADMIN_USER=$1
DOCKER_USER=$2
DOCKER_PASS=$3
DOCKER_REGISTRY=$4
AQUA_IMAGE=$5
AQUA_CONTAINER_NAME=$6
AQUA_DB_PASSWORD=$7
AQUA_LICENSE_TOKEN=$8
AQUA_ADMIN_PASSWORD=$9
echo "step end: globals"

echo "AQUA_ADMIN_PASSWORD: $AQUA_ADMIN_PASSWORD"

echo "step start: install docker-ce"
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce jq
sudo groupadd docker
sudo usermod -aG docker $ADMIN_USER
sudo systemctl start docker
sudo systemctl enable docker
sleep 10
docker version
lExitCode=$?
if [ $lExitCode == "0" ];then
  echo "Docker installed successfully"
else
  echo "Failed to install docker, exit code : $lExitCode, exiting"
  exit 1
fi
echo "step end: install docker-ce"

#Docker login
echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $DOCKER_REGISTRY
lExitCode=$?
if [ $lExitCode == "0" ];then
  echo "Sucessfully logged in to DOCKER_REGISTRY"
else
  echo "Failed to login to DOCKER_REGISTRY, exit code : $lExitCode , exiting"
  exit 1
fi

#Run Aqua CASP
echo "step start: deploy Aqua CSP"
docker run -d -p 5432:5432 -p 3622:3622 -p 8080:8080 --name $AQUA_CONTAINER_NAME \
   -e POSTGRES_PASSWORD=${AQUA_DB_PASSWORD} \
   -e SCALOCK_DBUSER=postgres \
   -e SCALOCK_DBPASSWORD=${AQUA_DB_PASSWORD} \
   -e SCALOCK_DBNAME=scalock \
   -e SCALOCK_DBHOST=$(hostname -i) \
   -e SCALOCK_AUDIT_DBUSER=postgres \
   -e SCALOCK_AUDIT_DBPASSWORD=${AQUA_DB_PASSWORD} \
   -e SCALOCK_AUDIT_DBNAME=slk_audit \
   -e SCALOCK_AUDIT_DBHOST=$(hostname -i) \
   -e LICENSE_TOKEN=${AQUA_LICENSE_TOKEN} \
   -e ADMIN_PASSWORD=${AQUA_ADMIN_PASSWORD} \
   -v /var/lib/postgresql/data:/var/lib/postgresql/data \
   -v /var/run/docker.sock:/var/run/docker.sock \
 $AQUA_IMAGE
 
 lExitCode=$?
if [ $lExitCode == "0" ];then
  echo "Sucessfully ran $AQUA_IMAGE"
else
  echo "Failed to run $AQUA_IMAGE, exit code : $lExitCode , exiting"
  exit 1
fi
echo "step start: deploy Aqua CSP"
