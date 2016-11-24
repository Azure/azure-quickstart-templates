#!/bin/bash
DTRDNS=$1
echo $(date) " - Starting Script"
sudo docker run --rm  --name ucp -v /var/run/docker.sock:/var/run/docker.sock  docker/ucp:1.1.0 id 1 > /tmp/id
INSTANCEID=$(cat /tmp/id)
sudo docker run --rm -i --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp restore --root-ca-only --passphrase ddconazure --id $(cat /tmp/id) < /tmp/backup.tar

export DOMAIN_NAME=$DTRDNS
openssl s_client -connect $DOMAIN_NAME:443 -showcerts </dev/null 2>/dev/null | \
openssl x509 -outform PEM | sudo tee /usr/local/share/ca-certificates/$DOMAIN_NAME.crt
sudo update-ca-certificates
sudo service docker restart