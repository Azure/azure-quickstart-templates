#!/bin/bash

# Update system to latest packages and install dependencies
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion pyOpenSSL httpd-tools

# Install the epel repo if not already present
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Clean yum metadata and cache to make sure we see the latest packages available
yum -y clean all

# Disable EPEL to prevent unexpected packages from being pulled in during installation.
yum-config-manager epel --disable

# Install Docker 1.9.1 
yum -y install docker-1.9.1-40.el7

# Create thin pool logical volume for Docker
echo "DEVS=/dev/sdc" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
docker-storage-setup

# Enable and start Docker services
systemctl enable docker
systemctl start docker

