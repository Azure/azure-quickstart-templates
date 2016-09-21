#!/bin/bash

# this script will be copied to each cluster node and executed from the jump box for each node (using dsh)
# Note: this script will fail on Ubuntu 16.04 LTS due to an unmet package dependency. Use Ubuntu 14.04 LTS instead.
# Tested to work on Ubuntu 14.04 LTS with MariaDB 10.1

# first parameter $1: MySQL root password

sudo apt-get -y install software-properties-common debconf-utils python-software-properties rsync netcat-openbsd
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository "deb [arch=amd64,i386] http://ftp.utexas.edu/mariadb/repo/10.1/ubuntu trusty main"
sudo apt-get update
sudo apt-get -y remove mysql-server && sudo apt-get -y autoremove
echo "mariadb-server-10.1 mysql-server/root_password password $1" | sudo debconf-set-selections
echo "mariadb-server-10.1 mysql-server/root_password_again password $1" | sudo debconf-set-selections
sudo apt-get install -y mariadb-client-10.1 mariadb-server-10.1