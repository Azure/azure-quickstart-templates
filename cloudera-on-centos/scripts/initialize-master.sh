#!/bin/bash

# Put the command line parameters into named variables
IPPREFIX=$1
NAMEPREFIX=$2
NAMESUFFIX=$3
NAMENODES=$4
DATANODES=$5
ADMINUSER=$6

sh ./initialize-node.sh $ADMINUSER

# Converts a domain like machine.domain.com to domain.com by removing the machine name
NAMESUFFIX=`echo $NAMESUFFIX | sed 's/^[^.]*\.//'`

#use the key from the key vault as the SSH private key
openssl rsa -in /var/lib/waagent/*.prv -out /home/$ADMINUSER/.ssh/id_rsa
chmod 600 /home/$ADMINUSER/.ssh/id_rsa
chown $ADMINUSER /home/$ADMINUSER/.ssh/id_rsa

#Generate IP Addresses for the cloudera setup
NODES=()

let "NAMEEND=NAMENODES-1"
for i in $(seq 0 $NAMEEND)
do 
  let "IP=i+10"
  NODES+=("$IPPREFIX$IP:${NAMEPREFIX}-nn$i:${NAMEPREFIX}-nn$i.$NAMESUFFIX")
done

let "DATAEND=DATANODES-1"
for i in $(seq 0 $DATAEND)
do 
  let "IP=i+20"
  NODES+=("$IPPREFIX$IP:${NAMEPREFIX}-dn$i:${NAMEPREFIX}-dn$i.$NAMESUFFIX")
done

IFS=',';NODE_IPS="${NODES[*]}";IFS=$' \t\n'

#sh bootstrap-cloudera.sh 'cloudera' "$IPPREFIX9:${NAMEPREFIX}-mn:${NAMEPREFIX}-mn.$NAMESUFFIX" $NODE_IPS false testuser >> /home/$ADMINUSER/bootstrap-cloudera.log
