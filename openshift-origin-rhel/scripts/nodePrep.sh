#!/bin/bash

# Update system to latest packages and install dependencies
yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion pyOpenSSL
# yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm

# sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

# Install Ansible

# Install the epel repo if not already present
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# Clean yum metadata and cache to make sure we see the latest packages available
yum -y clean all
# Install the ansible 1.9.4 package directly from koji
yum -y install https://kojipkgs.fedoraproject.org//packages/ansible/1.9.4/1.el7/noarch/ansible-1.9.4-1.el7.noarch.rpm
# Disable EPEL to prevent unexpected packages from being pulled in during installation.
yum-config-manager epel --disable


# Install Docker
yum -y install docker

# Create thin pool logical volume for Docker
echo "DEVS=/dev/sdc" >> /etc/sysconfig/docker-storage-setup
echo "VG=docker-vg" >> /etc/sysconfig/docker-storage-setup
docker-storage-setup

# Enable and start Docker services
systemctl enable docker
systemctl start docker

