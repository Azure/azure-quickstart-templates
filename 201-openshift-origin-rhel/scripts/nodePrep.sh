#!/bin/bash

# Update system to latest packages and install dependencies
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion pyOpenSSL
yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm

sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

# Install Ansible

yum -y --enablerepo=epel install ansible1.9

# Install Docker
yum -y install docker

# Create thin pool logical volume for Docker
echo "DEVS=/dev/sdc" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
docker-storage-setup

# Enable and start Docker services
systemctl enable docker
systemctl start docker