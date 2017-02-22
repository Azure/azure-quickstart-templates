#!/bin/bash
echo $(date) " - Starting Script"

# Update system to latest packages and install dependencies
echo $(date) " - Install base packages and update system to latest packages"
yum -y update --exclude=WALinuxAgent
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion pyOpenSSL httpd-tools

# Install the epel repo if not already present
yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm

# Clean yum metadata and cache to make sure we see the latest packages available
yum -y clean all

# Install Docker 1.12.5
echo $(date) " - Installing Docker 1.12.5"
yum -y install docker-1.12.5

# Create thin pool logical volume for Docker
echo $(date) " - Creating thin pool logical volume for Docker and staring service"

DOCKERVG=$( parted -m /dev/sda print all 2>/dev/null | grep unknown | grep /dev/sd | cut -d':' -f1 )

echo "DEVS=${DOCKERVG}" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
docker-storage-setup
if [ $? -eq 0 ]
then
   echo "Docker thin pool logical volume created successfully"
else
   echo "Error creating logical volume for Docker"
   exit 3
fi

# Enable and start Docker services
systemctl enable docker
systemctl start docker

echo $(date) " - Script Complete"
