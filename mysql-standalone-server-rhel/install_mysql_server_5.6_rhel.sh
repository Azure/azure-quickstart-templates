#!/bin/bash

mysqlPassword=$1

#get repo
wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum localinstall -y mysql-community-release-el6-5.noarch.rpm

#install
yum install mysql-community-server -y

#start
service mysqld start

#set root password
mysqladmin -uroot password "$mysqlPassword" 2> /dev/null

#restart
service mysqld restart

#auto-start 
chkconfig mysqld on


