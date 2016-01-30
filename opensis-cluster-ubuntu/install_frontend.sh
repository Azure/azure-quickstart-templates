#!/bin/bash
apt-get -y update

# set up a silent install of MySQL
dbpass=$1

export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.6 mysql-server/root_password password $dbpass | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $dbpass | debconf-set-selections

# install the LAMP stack
apt-get -y install apache2 mysql-server php5 php5-mysql  

# install OpenSIS
cd /var/www/html
wget http://sourceforge.net/projects/opensis-ce/files/opensis6.0.zip/download -O opensis.zip
apt-get install unzip
unzip opensis.zip

# make the opensis-ce directory writable
chown -R www-data opensis-ce
chmod -R 770 opensis-ce

# add port 8000 for admin access
perl -0777 -p -i -e 's/Listen 80/Listen 80\nListen 8080/ig' /etc/apache2/ports.conf
perl -0777 -p -i -e 's/\*:80/*:80 *:8080/g' /etc/apache2/sites-enabled/000-default.conf

# restart Apache
apachectl restart
