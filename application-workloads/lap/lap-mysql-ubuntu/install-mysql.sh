#!/bin/bash

LAPIP=$1

apt-get -y update

#no password prompt while installing mysql server
export DEBIAN_FRONTEND=noninteractive

#install mysql server
apt-get -y install mysql-server
cp -p /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
sed -i 's/\(bind-address\)/#\1/' /etc/mysql/my.cnf
service mysql restart
#allow $LAPIP to access
mysql -u root -e "use mysql;grant all privileges on *.* to 'root'@'$LAPIP';flush privileges"



