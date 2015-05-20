#!/bin/sh
date > /tmp/dummy 2>&1
whoami >> /tmp/dummy 2>&1
echo $@ >> /tmp/dummy 2>&1

if [ "$#" -ne 6 ]; then
  echo "Usage: $0 MASTER_NAME MASTER_IP WORKER_NAME WORKER_IP_BASE WORKER_IP_START NUM_OF_VM " >> /tmp/dummy
  exit 1
fi

# Update hosts file
MASTER_NAME=$1
MASTER_IP=$2
WORKER_NAME=$3
WORKER_IP_BASE=$4
WORKER_IP_START=$5
NUM_OF_VM=$6

echo $MASTER_IP $MASTER_NAME >> /etc/hosts

i=0
while [ $i -lt $NUM_OF_VM ]
do
   workerip=`expr $i + $WORKER_IP_START`
   echo 'I have host - worker'$i >> /tmp/dummy 2>&1
   echo $WORKER_IP_BASE$workerip 'worker'$i >> /etc/hosts
   i=`expr $i + 1`
done

sudo apt-get update >> /tmp/dummy 2>&1
#apt-get upgrade -y >> /tmp/dummy 2>&1
sudo chmod g-w /var/log >> /tmp/dummy 2>&1
sudo apt-get install slurm-llnl -y >> /tmp/dummy 2>&1
#sudo apt-get install expect -y >> /tmp/dummy 2>&1
#cd ~/.ssh
#ssh-keygen -f id_rsa -t rsa -N ''


exit 0
