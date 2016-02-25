#!/bin/bash

mysqlPassword=$1

#get repo
wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
yum localinstall -y mysql-community-release-el6-5.noarch.rpm

#install mysql 5.6
#sed -i '/mysql55/,/mysql56/s/enabled=0/enabled=1/' /etc/yum.repos.d/mysql-community.repo
#sed -i '/mysql56/,/mysql57/s/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
yum install mysql-community-server -y

#install apache 2.4 php5
yum install httpd php php-mysql -y


#start mysql,httpd
service mysqld start
service httpd start

#set mysql root password
mysqladmin -uroot password "$mysqlPassword" 2> /dev/null

#restart mysql
service mysqld restart

#auto-start 
chkconfig mysqld on
chkconfig httpd on
chkconfig firewalld off
service firewalld stop

#create test pages
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF

#mysql connection test file
cat > /var/www/html/mysql.php <<EOF
<?php
\$link = mysql_connect('localhost', '', '');
if (!\$link) {
    die('Could not connect:' . mysql_error());
}
echo 'Connected sucessfully';
?>
EOF


