#!/bin/sh
date > /tmp/dummy 2>&1
whoami >> /tmp/dummy 2>&1
echo $@ >> /tmp/dummy 2>&1

if [ "$#" -ne 8 ]; then
  echo "Usage: $0 MASTER_NAME MASTER_IP WORKER_NAME WORKER_IP_BASE WORKER_IP_START NUM_OF_VM ADMIN_USERNAME ADMIN_PASSWORD" >> /tmp/dummy
  exit 1
fi

# Update hosts file
MASTER_NAME=$1
MASTER_IP=$2
WORKER_NAME=$3
WORKER_IP_BASE=$4
WORKER_IP_START=$5
NUM_OF_VM=$6
ADMIN_USERNAME=$7
ADMIN_PASSWORD=$8

echo $MASTER_IP $MASTER_NAME >> /etc/hosts

sudo -u $ADMIN_USERNAME sh -c "mkdir /home/$ADMIN_USERNAME/.ssh/;echo Host worker\* > /home/$ADMIN_USERNAME/.ssh/config; echo StrictHostKeyChecking no >> /home/$ADMIN_USERNAME/.ssh/config; echo UserKnownHostsFile=/dev/null >> /home/$ADMIN_USERNAME/.ssh/config"

if ! [ -f /home/$ADMIN_USERNAME/.ssh/id_rsa ]; then
    sudo -u $ADMIN_USERNAME sh -c "ssh-keygen -f id_rsa -t rsa -N ''"
fi

sudo apt-get install sshpass -y >> /tmp/dummy 2>&1

i=0
while [ $i -lt $NUM_OF_VM ]
do
   workerip=`expr $i + $WORKER_IP_START`
   echo 'I have host - worker'$i >> /tmp/dummy 2>&1
   echo $WORKER_IP_BASE$workerip 'worker'$i >> /etc/hosts
   sudo -u $ADMIN_USERNAME sh -c "sshpass -p '$ADMIN_PASSWORD' ssh-copy-id worker$i"
   i=`expr $i + 1`
done

sudo apt-get update >> /tmp/dummy 2>&1
sudo chmod g-w /var/log >> /tmp/dummy 2>&1
sudo apt-get install slurm-llnl -y >> /tmp/dummy 2>&1

exit 0
