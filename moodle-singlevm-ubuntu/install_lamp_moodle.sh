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

# install Moodle
cd /var/www/html
wget https://download.moodle.org/download.php/direct/stable30/moodle-3.0.2.zip -O moodle.zip
apt-get install unzip
unzip moodle.zip

# make the moodle directory writable for owner
chown -R www-data moodle
chmod -R 770 moodle

# create moodledata directory
mkdir /var/www/moodledata
chown -R www-data /var/www/moodledata
chmod -R 770 /var/www/moodledata

# create cron entry
# It is scheduled for once per day. It can be changed as needed.
echo '0 0 * * * php /var/www/html/moodle/admin/cli/cron.php > /dev/null 2>&1' > cronjob
crontab cronjob

# restart MySQL
service mysql restart

# restart Apache
apachectl restart
