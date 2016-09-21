#!/bin/bash

# this script will be copied to each cluster node and executed from the jump box for each node (using dsh)
# Tested to work on Ubuntu 14.04 LTS with MariaDB 10.1

# First parameter $1: gcomm cluster address
# Second paramter $2: InnoDB buffer pool size
IP=`hostname --ip-address`

replace "wsrep_node_address=" "wsrep_node_address=\"$IP\"" -- ~/cluster.cnf
replace "wsrep_cluster_address=" "wsrep_cluster_address=\"$1\"" -- ~/cluster.cnf
replace "innodb_buffer_pool_size=" "innodb_buffer_pool_size=\"$2\"" -- ~/cluster.cnf

sudo service mysql stop
sudo cp ~/cluster.cnf /etc/mysql/conf.d/cluster.cnf