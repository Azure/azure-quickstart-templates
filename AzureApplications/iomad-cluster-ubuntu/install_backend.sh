#!/bin/bash
apt-get -y update
apt-get -y install python-software-properties
add-apt-repository -y ppa:ondrej/php5-oldstable
apt-get -y update

# set up a silent install of MySQL
dbpass=$1

export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.6 mysql-server/root_password password $dbpass | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $dbpass | debconf-set-selections

# install the LAMP stack
apt-get -y install apache2 mysql-client mysql-server php5

# install iomad requirements
apt-get -y install graphviz aspell php5-pspell php5-curl php5-gd php5-intl php5-mysql php5-xmlrpc php5-ldap

# Allow remote connection
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# create iomad database
MYSQL=`which mysql`

Q1="CREATE DATABASE moodle DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
Q2="GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO 'root'@'%' IDENTIFIED BY '$dbpass' WITH GRANT OPTION;"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

$MYSQL -uroot -p$dbpass -e "$SQL"

# Create Azure file share that will be used by front end VM's for moodledata directory
SharedStorageAccountName=$2
SharedAzureFileName=$3
SharedStorageAccountKey=$4

apt-get -y install nodejs-legacy
apt-get -y install npm
npm install -g azure-cli

sudo azure storage share create $SharedAzureFileName -a $SharedStorageAccountName -k $SharedStorageAccountKey

# restart MySQL
service mysql restart

# restart Apache
apachectl restart
