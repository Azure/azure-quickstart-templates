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

# install moodle requirements
apt-get -y install graphviz aspell php5-pspell php5-curl php5-gd php5-intl php5-mysql php5-xmlrpc php5-ldap

# create moodle database
MYSQL=`which mysql`

Q1="CREATE DATABASE moodle DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
Q2="GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO 'root'@'%' IDENTIFIED BY '$dbpass' WITH GRANT OPTION;"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

$MYSQL -uroot -p$dbpass -e "$SQL"

# # mount moodledata disk
# # The ARM script only mounts a single data disk.  It is safe 
# # to assume that on a new VM, this data disk is located at /dev/sdc.

# # If you have a more complicated setup, then do examine what this
# # script is doing and modify accordingly.

# # create a partition table for the disk
# parted -s /dev/sdc mklabel msdos

# # create a single large partition
# parted -s /dev/sdc mkpart primary ext4 0\% 100\%

# # install the file system
# mkfs.ext4 /dev/sdc1

# # create the mount point
# mkdir -p /moodledata

# # mount the disk
# mount /dev/sdc1 /moodledata/

# # premissions
# chown -R www-data /moodledata
# chmod -R 777 /moodledata

# # add mount to /etc/fstab to persist across reboots
# echo "/dev/sdc1    /moodledata/    ext4    defaults 0 0" >> /etc/fstab

# restart MySQL
service mysql restart

# Allow remote connection
echo "Updating mysql configs in /etc/mysql/my.cnf."
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "Updated mysql bind address in /etc/mysql/my.cnf to 0.0.0.0 to allow external connections."
sudo service mysql stop
sudo service mysql start

# restart Apache
apachectl restart

# Create file share
SharedStorageAccountName=$2
SharedAzureFileName=$3
SharedStorageAccountKey=$4

sudo apt-get -y install nodejs-legacy
sudo apt-get -y install npm
sudo npm install -g azure-cli

sudo azure storage share create $SharedAzureFileName -a $SharedStorageAccountName -k $SharedStorageAccountKey
