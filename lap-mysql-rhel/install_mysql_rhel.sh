#!/bin/bash

LAPIP=$1

#get repo
wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum localinstall -y mysql-community-release-el6-5.noarch.rpm

#install mysql 5.6
yum install mysql-community-server -y


#start 
service mysqld start


#allow $LAPIP to access
mysql -u root -e "use mysql;grant all privileges on *.* to 'root'@'$LAPIP';flush privileges"

#restart
service mysqld restart

#auto-start 
chkconfig mysqld on

#disable firewalld and selinux
service firewalld stop
chkconfig firewalld off
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux