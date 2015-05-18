#!/bin/sh
date > /tmp/dummy 2>&1
whoami >> /tmp/dummy 2>&1

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 NUM_OF_VM" >> /tmp/dummy
  exit 1
fi

sudo apt-get update >> /tmp/dummy 2>&1
#apt-get upgrade -y >> /tmp/dummy 2>&1
sudo chmod g-w /var/log >> /tmp/dummy 2>&1
sudo apt-get install slurm-llnl -y >> /tmp/dummy 2>&1
#sudo apt-get install expect -y >> /tmp/dummy 2>&1
#cd ~/.ssh
#ssh-keygen -f id_rsa -t rsa -N ''

i=0
while [ $i -lt $1 ]
do
   echo 'I have host - worker'$i >> /tmp/dummy 2>&1
   i=`expr $i + 1`
done

exit 0

