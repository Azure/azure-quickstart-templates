#!/bin/bash

mysqlPassword=$1
osUser=$2

apt-get update

#another way of installing mysql server in a Non-Interactive mode
echo "mysql-server-5.6 mysql-server/root_password password $mysqlPassword" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password $mysqlPassword" | sudo debconf-set-selections

#install mysql-server 5.5
apt-get -y install mysql-server

#configure mysql
sed -i 's/^bind-address/#bind-address/' /etc/mysql/my.cnf
sed -i 's/^#server-id/server-id/' /etc/mysql/my.cnf
sed -i 's/#log_bin/log_bin/' /etc/mysql/my.cnf
mysql -uroot -p$mysqlPassword -e "grant replication slave on *.* to 'repluser'@'%' identified by 'replpass';grant all privileges on *.* to 'root'@'%' identified by '$mysqlPassword';flush privileges;"
service mysql restart

#install mha node
cd /tmp/
wget http://mysql-master-ha.googlecode.com/files/mha4mysql-node_0.53_all.deb > /dev/null 2>&1
apt-get update
apt-get install libdbd-mysql-perl -y
dpkg -i mha4mysql-node_0.53_all.deb


mkdir /var/log/masterha/
chown ${osUser}:${osUser} -R /var/log/masterha/
apt-get install acl -y
setfacl -m u:${osUser}:rx /var/lib/mysql
setfacl -Rdm u:${osUser}:r /var/lib/mysql
setfacl -m u:${osUser}:r /var/lib/mysql/*



