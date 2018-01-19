#!/bin/bash

dbpass=$1
moodleVersion=$2
installOfficePlugins=$3

# Installing development tools
yum install -y make bison bzr cmake gcc gcc-c++ ncurses-devel perl 
yum install -y 'perl(Data::Dumper)'

#Iterate loop to avoid below commands failing
CommandStatus=$?

for i in {1..10}
do
if [ $CommandStatus -eq 0 ]; then
break
else
yum install -y make bison bzr cmake gcc gcc-c++ ncurses-devel perl
CommandStatus=$?
fi
done

yum -y install kernel-headers --disableexcludes=main
CommandStatus=$?

for i in {1..10}
do
if [ $CommandStatus -eq 0 ]; then
break
else
yum -y install kernel-headers --disableexcludes=main
CommandStatus=$?
fi
done

#Secure centos security 
yum -y install gamin-python
yum -y install epel-release
yum -y install fail2ban fail2ban-systemd 
yum -y update selinux-policy*

yum localinstall http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm -y
yum install -y puppet git
git clone https://legeek@bitbucket.org/legeek/bkraft-securingc7.git

cd bkraft-securingc7
git checkout -b puppet4.0
git branch --set-upstream-to=remotes/origin/puppet4.0
git pull
cd ..

cp -r bkraft-securingc7/ /usr/share/puppet/modules/

cd /usr/share/puppet/modules/
puppet apply -e 'include bkraft-securingc7::services'
puppet apply  -e 'include bkraft-securingc7::fail2ban'
puppet apply  -e 'include bkraft-securingc7::openssh'
puppet apply  -e 'include bkraft-securingc7::general'

echo "[sshd]
enabled = true
port = 22000
logpath = %(sshd_log)s
maxretry = 3
bantime = 86400 " >>/etc/fail2ban/jail.d/sshd.local
systemctl enable fail2ban
systemctl start fail2ban

mkdir /opt/setup
cd /opt/setup

#Download Apache Source code
wget https://archive.apache.org/dist/httpd/httpd-2.4.20.tar.gz

#Download APR Apache dependency Source code
wget http://mirror.ventraip.net.au/apache/apr/apr-1.5.2.tar.gz

#Download APR-Util Apache dependency Source code
wget http://mirror.ventraip.net.au/apache//apr/apr-util-1.5.4.tar.gz

#Download PHP Source code
wget http://au2.php.net/get/php-5.4.40.tar.gz/from/this/mirror

#Download MySql Source code
wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.14.tar.gz

#Extract all files
tar xvzf httpd-2.4.20.tar.gz
tar xvzf apr-1.5.2.tar.gz
tar xvzf apr-util-1.5.4.tar.gz
tar xvzf mysql-5.6.14.tar.gz
tar xvzf mirror

#Enabling firewall and opening HTTP and HTTPS port for public
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=public --add-service=http	
firewall-cmd --permanent --zone=public --add-service=https	
firewall-cmd --reload

# Compile and install MySql from source code
cd /opt/setup/mysql-5.6.14/

#Add mysql user and group
groupadd mysql
useradd -g mysql -s /bin/false mysql

CC='gcc' CXX='g++'
export CC CXX

mkdir /usr/local/mysql  
mkdir /usr/local/mysql/data

#Build and compile mysql source code
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE_ENGINE:BOOL=ON
make -j15     
make install

#Added mysql user permission to mysql installation folder 
chown -R mysql:mysql /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql/data
yes | cp support-files/my-default.cnf /etc/my.cnf
yes | cp support-files/mysql.server /etc/init.d/
chmod 755 /etc/init.d/mysql.server
cd /etc/init.d
cp mysql.server mysql.server.respaldo

/usr/bin/rpm -Uvf ftp://ftp.muug.mb.ca/mirror/centos/7.2.1511/os/x86_64/Packages/perl-Data-Dumper-2.145-3.el7.x86_64.rpm
cd /usr/local/mysql/
scripts/mysql_install_db --user=mysql

/etc/init.d/mysql.server start

# Enable barracuda table format
echo 'innodb_file_per_table = 1' >> /etc/my.cnf
echo 'innodb_file_format = barracuda' >> /etc/my.cnf

# Restart mysql
/etc/init.d/mysql.server restart

# Compile and install Apache from source code
cd /opt/setup/httpd-2.4.20
yum -y install pcre-devel.x86_64 openssl-devel.x86_64
#Apache depends on Apr and Apr-util packages and move to srclib
mv /opt/setup/apr-1.5.2 /opt/setup/httpd-2.4.20/srclib/apr
mv /opt/setup/apr-util-1.5.4 /opt/setup/httpd-2.4.20/srclib/apr-util

./configure --prefix=/usr/local/apache --enable-ssl --with-ssl=/usr/local/ssl --enable-so --enable-rewrite --enable-deflate --enable-expires
make -j11
make install

mkdir -p /www/htdocs

#Add index.html and index.php file to check apache and php server running
echo "<html><body> <h1>Hello world</h1></body></html>" >>/www/htdocs/index.html
 echo "<?php echo phpinfo(); ?>" >>/www/htdocs/index.php

#Add apache user and group
groupadd apache
useradd -g apache apache
cd /usr/local/apache/conf
cp httpd.conf httpd.conf.respaldo

# Apache Hardening steps
echo "ServerTokens Prod" >>httpd.conf
echo "ServerSignature Off" >>httpd.conf

sed -i 's/User[[:space:]]daemon/User apache/' httpd.conf
sed -i 's/Group[[:space:]]daemon/Group apache/' httpd.conf
sed -i 's|/usr/local/apache/htdocs|/www/htdocs|' httpd.conf
sed -i 's|index.html|index.html index.php|' httpd.conf
sed -i 's|Indexes| |' httpd.conf
sed -i 's|MultiViews | |' httpd.conf
sed -i 's|access_log" [[:space:]] common|access_log" combined|' httpd.conf

# Set php configuration for apache
echo " application/x-httpd-php php html" >> mime.types 

echo "<IfModule mod_deflate.c>
# compress text, html, javascript, css, xml:
AddOutputFilterByType DEFLATE text/plain
AddOutputFilterByType DEFLATE text/html
AddOutputFilterByType DEFLATE text/xml
AddOutputFilterByType DEFLATE text/css
AddOutputFilterByType DEFLATE application/xml
AddOutputFilterByType DEFLATE application/xhtml+xml
AddOutputFilterByType DEFLATE application/rss+xml
AddOutputFilterByType DEFLATE application/javascript
AddOutputFilterByType DEFLATE application/x-javascript
AddOutputFilterByType DEFLATE image/x-icon
</IfModule>" >>/usr/local/apache/conf/httpd.conf

# Restart apache server
/usr/local/apache/bin/apachectl  restart

# Install PHP
cd /opt/setup/php-5.4.40/
yum -y install libjpeg-turbo-devel-1.2.1-1.el6.x86_64 libpng.x86_64 libpng-devel.x86_64 giflib.x86_64 giflib.x86_64 gd.x86_64 libXpm.x86_64 freetype-devel.x86_64 libxml2.x86_64 libxml2-devel.x86_64 mingw32-iconv-static.noarch openssl098e.x86_64 openldap-devel libXpm-devel libjpeg-devel libcurl-devel.x86_64

# Pre-instalaltion requirement for php
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh  http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum --enablerepo=remi install -y libmcrypt libmcrypt-devel  libicu-devel php-mbstring php-mcrypt gd gd-devel php-soap graphviz aspell php-pspell php-ldap php-xmlrpc php-gd php-mysql php-intl php-opcache 

ln -s /usr/lib64/libldap.so /usr/lib/libldap.so
ln -s /usr/lib64/libldap_r.so /usr/lib/libldap_r.so
ln -s /usr/lib64/libmysqlclient.so /usr/lib64/mysql/libmysqlclient.so

./configure --with-apxs2=/usr/local/apache/bin/apxs --with-openssl --with-zlib --with-libxml-dir  --with-mysql=mysqlnd --enable-ftp --prefix=/usr/local/php --enable-mbstring=all --enable-mbregex --with-gd --with-jpeg-dir --with-png-dir --with-xpm-dir=/usr --with-freetype-dir --enable-gd-native-ttf --with-ldap=shared --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-mcrypt --with-curl --enable-zip --enable-sockets --enable-opcache --with-libdir=lib64 --enable-fpm --with-xmlrpc  --enable-intl --enable-soap
make -j11
make install

# PHP Configuration
sed -i "s/memory_limit.*/memory_limit = 512M/" /etc/php.ini
cp php.ini-production /usr/local/php/lib/php.ini

# Enable php soap
echo "extension=/usr/lib64/php/modules/soap.so">>/etc/php.ini

# Enable php opcache
echo "zend_extension=/usr/lib64/php/modules/opcache.so" >>/etc/php.ini
echo "opcache.use_cwd = 1
opcache.validate_timestamps = 1
opcache.save_comments = 1
opcache.enable_file_override = 0 " >>  /etc/php.d/opcache.ini
echo "
[opcache]
opcache.enable = 1
opcache.memory_consumption = 128
opcache.max_accelerated_files = 8000
opcache.revalidate_freq = 60
 
; Required for Moodle
opcache.use_cwd = 1
opcache.validate_timestamps = 1
opcache.save_comments = 1
opcache.enable_file_override = 0 " >>/etc/php.ini

# Restart apache server
/usr/local/apache/bin/apachectl restart

# Install Moodle
cd /www/htdocs
wget https://github.com/moodle/moodle/archive/$moodleVersion.zip
unzip $moodleVersion.zip
mv moodle-$moodleVersion moodle

# Set permission to moodle
chmod -R 750 /www/htdocs/moodle
chown -R apache:apache /www/htdocs/moodle

# Make moodle data directory
mkdir /www/moodledata

# Set permission to moodledata
chmod -R 750 /www/moodledata
chown -R apache:apache /www/moodledata

# Restart apache server
/usr/local/apache/bin/apachectl restart

# Install Office 365 plugins if asked for
if [ "$installOfficePlugins" = "True" ]; then
    curl -k --max-redirs 10 https://github.com/Microsoft/o365-moodle/archive/$moodleVersion.zip -L -o o365.zip
    unzip o365.zip
    
    # The plugins below are not required for new installations
    rm -rf o365-moodle-$moodleVersion/blocks/onenote
    rm -rf o365-moodle-$moodleVersion/local/m*
    rm -rf o365-moodle-$moodleVersion/local/o365docs
    rm -rf o365-moodle-$moodleVersion/local/office365
    rm -rf o365-moodle-$moodleVersion/local/onenote
    rm -rf o365-moodle-$moodleVersion/mod/assign
    rm -rf o365-moodle-$moodleVersion/user/profile/
    rm -rf o365-moodle-$moodleVersion/repository/onenote	
    cp -r o365-moodle-$moodleVersion/* moodle
    
    cp -r o365-moodle-$moodleVersion/* moodle
    rm -rf o365-moodle-$moodleVersion
fi

# Create moodle database and set permission to root user
/usr/local/mysql/bin/mysql -u root -e "use mysql;CREATE DATABASE moodle DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;flush privileges; UPDATE user SET password=PASSWORD('$dbpass') WHERE User='root';"
/usr/local/mysql/bin/mysql -u root -e "grant all privileges on *.* to root@'localhost'";


# Restart mysql and apache 
/etc/init.d/mysql.server restart
/usr/local/apache/bin/apachectl restart
