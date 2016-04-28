#!/bin/bash 
yum clean all
dbpass=$1
moodleVersion=$2
installOfficePlugins=$3

# Install apache
yum -y install httpd

#Install Mysql
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm

yum -y localinstall mysql57-community-release-el7-8.noarch.rpm

yum -y install mysql-community-server

service mysqld start

mysqlpwd=`grep 'temporary password' /var/log/mysqld.log | sed -e  's/.*root@localhost: //'`
mysqladmin -u root -p"$mysqlpwd" password "$dbpass"

#Install PHP
yum -y install php php-mysql
yum -y install php-iconv php-mbstring php-curl php-openssl php-tokenizer php-xmlpc php-soap php-ctype php-zip php-gd php-simplexml php-spl php-pcre php-dom php-xml php-intl php-json php-ldap php-pecl-apc


MYSQL=`which mysql`

Q1="CREATE DATABASE moodle DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
Q2="GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO 'root'@'%' IDENTIFIED BY '$dbpass' WITH GRANT OPTION;"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

#changing mysql password

$MYSQL -u root -p"$dbpass" -e "$SQL"

systemctl enable firewalld
systemctl start firewalld

systemctl enable httpd
systemctl start  httpd
#systemctl enable mysqld
#systemctl start mysqld

firewall-cmd --permanent --zone=public --add-service=http	
firewall-cmd --permanent --zone=public --add-service=https	
firewall-cmd --reload	

yum -y install unzip

cd /var/www/html

curl -k --max-redirs 10 https://github.com/moodle/moodle/archive/$moodleVersion.zip -L -o moodle.zip

unzip moodle.zip

mv moodle-$moodleVersion moodle

# install Office 365 plugins if asked for
if [ "$installOfficePlugins" = "True" ]; then
    curl -k --max-redirs 10 https://github.com/Microsoft/o365-moodle/archive/$moodleVersion.zip -L -o o365.zip
    unzip o365.zip
    cp -r o365-moodle-$moodleVersion/* moodle
    rm -rf o365-moodle-$moodleVersion
fi

chown -R apache:apache /var/www/html/moodle
chmod -R 755 /var/www/html/moodle

cd /var/www
mkdir moodledata 
chmod -R 755 /var/www/moodledata
chown -R apache:apache /var/www/moodledata

#service httpd restart
apachectl restart
#systemctl restart httpd

#Disabling SElinux
setenforce 0

