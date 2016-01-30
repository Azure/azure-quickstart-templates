#!/bin/bash
# This script gets a VM ready so DataStax OpsCenter can perform an install on it.

while getopts ":e:c:" opt; do
  echo "Option $opt set with value $OPTARG"
  case $opt in
    e)
      # List of successive cluster IP addresses represented as the starting address and a count used to increment the last octet (for example 10.0.0.5-3)
      NODE_IP_RANGE=$OPTARG
      ;;
    c)
      # Number of successive cluster IP addresses sent for NODE_IP_RANGE
      NUM_NODE_IP_RANGE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      ;;
  esac
done

IFS='-' read -a IP_RANGE <<< "${NODE_IP_RANGE}"
NODE_COUNT="${IP_RANGE[1]}"

echo "127.0.0.1 ${HOSTNAME}" >> /etc/hosts
echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
echo "10.0.0.5  opcvm" >> /etc/hosts
echo '*/1 * * * * sudo service walinuxagent start' > cronjob
crontab cronjob
for (( i=0; i<$NUM_NODE_IP_RANGE ; i++))
do
    for (( j=0; j<$NODE_COUNT ; j++))
    do
        echo "10.0.$i.$(expr $j + 6)  dc${i}vm${j}" >> /etc/hosts
    done
done

echo "Partitioning and formatting all attached data disks"
bash vm-disk-utils-0.1.sh

echo "Installing Java"
add-apt-repository -y ppa:webupd8team/java
apt-get -y update 
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get -y install oracle-java8-installer

echo "Modifying permissions"
chmod 777 /mnt
chmod 777 /datadisks

