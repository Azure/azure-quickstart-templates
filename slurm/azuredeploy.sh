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
if [ "$#" -ne 9 ]; then
  echo "Usage: $0 MASTER_NAME MASTER_IP WORKER_NAME WORKER_IP_BASE WORKER_IP_START NUM_OF_VM ADMIN_USERNAME ADMIN_PASSWORD TEMPLATE_BASE" >> /tmp/dummy
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
TEMPLATE_BASE=$9

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
sudo chmod g-w /var/log >> /tmp/dummy 2>&1 # Must do this before munge will generate key
sudo apt-get install slurm-llnl -y >> /tmp/dummy 2>&1

# Download slurm.conf and fill in the node info
SLURMCONF=/tmp/slurm.conf.$$
wget $TEMPLATE_BASE/slurm.template.conf -O $SLURMCONF >> /tmp/dummy 2>&1
sed -i -- 's/__MASTERNODE__/'"$MASTER_NAME"'/g' $SLURMCONF >> /tmp/dummy 2>&1
lastvm=`expr $NUM_OF_VM - 1`
sed -i -- 's/__WORKERNODES__/'"$WORKER_NAME"'[0-'"$lastvm"']/g' $SLURMCONF >> /tmp/dummy 2>&1
sudo cp -f $SLURMCONF /etc/slurm-llnl/slurm.conf >> /tmp/dummy 2>&1
sudo chown slurm /etc/slurm-llnl/slurm.conf >> /tmp/dummy 2>&1
sudo chmod o+w /var/spool # Write access for slurmctld log. Consider switch log file to another location
sudo -u slurm /usr/sbin/slurmctld >> /tmp/dummy 2>&1 # Start the master daemon service
sudo slurmd >> /tmp/dummy 2>&1 # Start the node

# Install slurm on all nodes by running apt-get
# Also push munge key and slurm.conf to them
mungekey=/tmp/munge.key.$$
sudo cp -f /etc/munge/munge.key $mungekey
sudo chown $ADMIN_USER $mungekey
i=0
while [ $i -lt $NUM_OF_VM ]
do
   worker=$WORKER_NAME$i

   sudo -u $ADMIN_USER scp $mungekey $ADMIN_USER@$worker:/tmp/munge.key >> /tmp/dummy 2>&1 
   sudo -u $ADMIN_USER scp $SLURMCONF $ADMIN_USER@$worker:/tmp/slurm.conf >> /tmp/dummy 2>&1

   sudo -u $ADMIN_USERNAME ssh $ADMIN_USERNAME@$worker >> /tmp/dummy 2>&1 << 'ENDSSH1'
      sudo chmod g-w /var/log
      sudo apt-get update
      sudo apt-get install slurm-llnl -y
      sudo cp -f /tmp/munge.key /etc/munge/munge.key
      sudo chown munge /etc/munge/munge.key
      sudo chgrp munge /etc/munge/munge.key
      sudo rm -f /tmp/munge.key
      sudo /usr/sbin/munged --force # ignore egregrious security warning
      sudo cp -f /tmp/slurm.conf /etc/slurm-llnl/slurm.conf
      sudo chown slurm /etc/slurm-llnl/slurm.conf
      sudo slurmd
   ENDSSH1

   i=`expr $i + 1`
done
rm -f $mungekey

# Restart slurm service on all nodes

exit 0
