#!/bin/bash
Usage(){
    echo "This script is to setup password-less ssh login from current host to a given remote host."
}

echo $(date) " - Starting Script"
#--------------------------------------------------------------
PASSWORD=$1
MASTERFQDN=$2
COUNT=$3
DTRDNS=$4
Port=220
DESTDIR="/tmp"
#--------------------------------------------------------------
#echo $PASSWORD
#echo $MASTERFQDN
#echo $COUNT
#--------------------------------------------------------------
apt-get install -y expect dos2unix sshpass
sleep 5
#--------------------------------------------------------------
sudo docker run --rm  --name ucp -v /var/run/docker.sock:/var/run/docker.sock  docker/ucp:1.1.0 id 1 > $DESTDIR/id
INSTANCEID=$(cat /tmp/id)
echo $INSTANCEID
sudo docker run --rm -i --name ucp  -v /var/run/docker.sock:/var/run/docker.sock  docker/ucp backup --root-ca-only --passphrase ddconazure --id $INSTANCEID > $DESTDIR/backup.tar
#--------------------------------------------------------------
USERNAME="ucpadmin"
#--------------------------------------------------------------
for i in $(seq $COUNT)
do
        echo $i
        SSHPort=$Port$i
        echo $SSHPort
        sshpass -p $PASSWORD ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p $SSHPort $USERNAME@$MASTERFQDN 'ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2' > $DESTDIR/output
        INSTANCEIP=`cat $DESTDIR/output | cut -d ' ' -f 1`
        echo $INSTANCEIP
        sshpass -p $PASSWORD scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $DESTDIR/backup.tar $USERNAME@$INSTANCEIP:/tmp
        done

export DOMAIN_NAME=$DTRDNS
openssl s_client -connect $DOMAIN_NAME:443 -showcerts </dev/null 2>/dev/null | \
openssl x509 -outform PEM | sudo tee /usr/local/share/ca-certificates/$DOMAIN_NAME.crt
sudo update-ca-certificates
sudo service docker restart