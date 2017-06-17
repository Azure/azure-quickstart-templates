#!/bin/bash -e
#
#Installing MySQL 5.7 which is available in default repo for Ubuntu 16.06
#

LOGFILE=/var/log/azure/mysql.log
echo "Installing MySQL 5.7 now...\n"

echo "mysql-server-5.7 mysql-server/root_password password password" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password password" | sudo debconf-set-selections
apt-get -y install mysql-server-5.7 mysql-client >> $LOGFILE 2>&1
MYSQLPASSWORD=$2
mysql -u root -p'password' -e "use mysql; UPDATE user SET authentication_string=PASSWORD('$MYSQLPASSWORD') WHERE User='root'; flush privileges;" >> $LOGFILE 2>&1

echo "Creating Badgr DB, Users and grating privileges...\n"
BADGRUSER=$1
BADGRUSERPWD=$2
BADGRDB=$3
mysql -u root -p$MYSQLPASSWORD <<MYSQL_SCRIPT
CREATE DATABASE badgr DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON $BADGRDB.* TO '$BADGRUSER'@'localhost' IDENTIFIED BY '$BADGRUSERPWD';
FLUSH PRIVILEGES;
MYSQL_SCRIPT