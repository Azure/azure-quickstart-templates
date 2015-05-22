#!/bin/sh

# This script can be found on https://github.com/YidingZhou/azure-quickstart-templates/blob/master/slurm/azuredeploy.sh
# This script is part of azure deploy ARM template
# This script assumes the Linux distribution to be Ubuntu (or at least have apt-get support)
# This script will install SLURM on a Linux cluster deployed on a set of Azure VMs

# Basic info
date > /tmp/dummy 2>&1
whoami >> /tmp/dummy 2>&1
echo $@ >> /tmp/dummy 2>&1

# Usage
if [ "$#" -ne 8 ]; then
  echo "Usage: $0 MASTER_NAME MASTER_IP WORKER_NAME WORKER_IP_BASE WORKER_IP_START NUM_OF_VM ADMIN_USERNAME ADMIN_PASSWORD" >> /tmp/dummy
  exit 1
fi

# Preparation steps - hosts and ssh
###################################

# Parameters
MASTER_NAME=$1
MASTER_IP=$2
WORKER_NAME=$3
WORKER_IP_BASE=$4
WORKER_IP_START=$5
NUM_OF_VM=$6
ADMIN_USERNAME=$7
ADMIN_PASSWORD=$8

# Update master node
echo $MASTER_IP $MASTER_NAME >> /etc/hosts

# Update ssh config file to ignore unknow host
# Note all settings are for azureuser, NOT root
sudo -u $ADMIN_USERNAME sh -c "mkdir /home/$ADMIN_USERNAME/.ssh/;echo Host worker\* > /home/$ADMIN_USERNAME/.ssh/config; echo StrictHostKeyChecking no >> /home/$ADMIN_USERNAME/.ssh/config; echo UserKnownHostsFile=/dev/null >> /home/$ADMIN_USERNAME/.ssh/config"

# Generate a set of sshkey under /honme/azureuser/.ssh if there is not one yet
if ! [ -f /home/$ADMIN_USERNAME/.ssh/id_rsa ]; then
    sudo -u $ADMIN_USERNAME sh -c "ssh-keygen -f /home/$ADMIN_USERNAME/.ssh/id_rsa -t rsa -N ''"
fi

# Install sshpass to automate ssh-copy-id action
sudo apt-get install sshpass -y >> /tmp/dummy 2>&1

# Loop through all worker nodes, update hosts file and copy ssh public key to it
# The script make the assumption that the node is called %WORKER+<index> and have
# static IP in sequence order
i=0
while [ $i -lt $NUM_OF_VM ]
do
   workerip=`expr $i + $WORKER_IP_START`
   echo 'I update host - $WORKER_NAME'$i >> /tmp/dummy 2>&1
   echo $WORKER_IP_BASE$workerip $WORKER_NAME$i >> /etc/hosts
   sudo -u $ADMIN_USERNAME sh -c "sshpass -p '$ADMIN_PASSWORD' ssh-copy-id $WORKER_NAME$i"
   i=`expr $i + 1`
done

# Install SLURM on master node
###################################

# Install the package
sudo apt-get update >> /tmp/dummy 2>&1
sudo chmod g-w /var/log >> /tmp/dummy 2>&1
sudo apt-get install slurm-llnl -y >> /tmp/dummy 2>&1

# Download slurm.conf and fill in the node info

# Install slurm on all nodes by running apt-get
# Also push munge key and slurm.conf to them

# Restart slurm service on all nodes

exit 0
