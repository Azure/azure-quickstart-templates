#!/bin/bash

dbpass=$1
SharedStorageAccountName=$2
SharedAzureFileName=$3
FullNameOfSite=$4
ShortNameOfSite=$5
MoodleAdminUser=$6
MoodleAdminPass=$7
MoodleAdminEmail=$8
moodleVersion=$9
installOfficePlugins=${10}
SharedStorageAccountKey=${11}
LoadbalancerFqdn=${12}
DbFqdn=${13}


#Installing development tools
yum install -y make bison bzr cmake gcc gcc-c++ ncurses-devel perl 

CommandStatus=$?
#Iterate loop to avoid below commands failing
while true
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

while true
do
if [ $CommandStatus -eq 0 ]; then
break
else
yum -y install kernel-headers --disableexcludes=main
CommandStatus=$?
fi
done

#Securing  centos 
yum -y install gamin-python
yum -y install epel-release
yum -y install fail2ban fail2ban-systemd 
yum -y update selinux-policy*

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
wget https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz

#Download APR-Util Apache dependency Source code
wget https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz

#Download PHP Source code
wget http://au2.php.net/get/php-5.4.40.tar.gz/from/this/mirror

#Extract all tar files
tar xvzf httpd-2.4.20.tar.gz
tar xvzf apr-1.5.2.tar.gz
tar xvzf apr-util-1.5.4.tar.gz
tar xvzf mirror

#Security Script
cd /
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

#Enable Firewwall and set http and https to public zone
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=public --add-service=http	
firewall-cmd --permanent --zone=public --add-service=https	
firewall-cmd --reload

# Compile and install Apache from source code
cd /opt/setup/httpd-2.4.20
yum -y install pcre-devel.x86_64 openssl-devel.x86_64
mv /opt/setup/apr-1.5.2 /opt/setup/httpd-2.4.20/srclib/apr
mv /opt/setup/apr-util-1.5.4 /opt/setup/httpd-2.4.20/srclib/apr-util

./configure --prefix=/usr/local/apache --enable-ssl --with-ssl=/usr/local/ssl --enable-so --enable-rewrite --enable-deflate --enable-expires
make
make install

#Add index.html and index.php file to check apache and php server running
mkdir -p /www/htdocs
echo "<html><body> <h1>Hello world</h1></body></html>" >>/www/htdocs/index.html
echo "<?php echo phpinfo(); ?>" >>/www/htdocs/index.php
 
 
#Create apache user and group 
groupadd apache
useradd -g apache apache
cd /usr/local/apache/conf
cp httpd.conf httpd.conf.respaldo

#Apache Hardening
echo "ServerTokens Prod" >>httpd.conf
echo "ServerSignature Off" >>httpd.conf

#Apache hardening script
sed -i 's/User[[:space:]]daemon/User apache/' httpd.conf
sed -i 's/Group[[:space:]]daemon/Group apache/' httpd.conf
sed -i 's|/usr/local/apache/htdocs|/www/htdocs|' httpd.conf
sed -i 's|index.html|index.html index.php|' httpd.conf
sed -i 's|Indexes| |' httpd.conf
sed -i 's|MultiViews | |' http.conf
sed -i 's|access_log" [[:space:]] common|access_log" combined|' httpd.conf

echo " application/x-httpd-php php html" >> mime.types 
echo "ServerTokens Prod" >>httpd.conf
echo "ServerSignature Off" >>httpd.conf

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

#Restart apache server
/usr/local/apache/bin/apachectl  restart

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

#Install Moodle
cd /www/htdocs
wget https://github.com/moodle/moodle/archive/$moodleVersion.zip

unzip $moodleVersion.zip
mv moodle-$moodleVersion moodle

#Set permission to moodle
chmod -R 755 /www/htdocs/moodle
chown -R apache:apache /www/htdocs/moodle

#Set permission to moodledata
mkdir /www/moodledata
chmod -R 755 /www/moodledata
chown -R apache:apache /www/moodledata

#Restart apache server
/usr/local/apache/bin/apachectl restart

# install Office 365 plugins if asked for
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
    
# Copy office plugins folder into moodle  and remove unzipped folder    
    cp -r o365-moodle-$moodleVersion/* moodle
    rm -rf o365-moodle-$moodleVersion
fi

#Restart apache server
/usr/local/apache/bin/apachectl restart

# mount share file on /var/www/moodledata
yum -y install samba-client samba-common cifs-utils
mount -t cifs //$SharedStorageAccountName.file.core.windows.net/$SharedAzureFileName /www/moodledata -o uid=$(id -u apache),vers=3.0,username=$SharedStorageAccountName,password=$SharedStorageAccountKey,dir_mode=0770,file_mode=0770 
	
#add mount to /etc/fstab to persist across reboots
chmod 770 /etc/fstab
echo "//$SharedStorageAccountName.file.core.windows.net/$SharedAzureFileName /www/moodledata cifs uid=$(id -u apache),vers=3.0,username=$SharedStorageAccountName,password=$SharedStorageAccountKey,dir_mode=0770,file_mode=0770" >> /etc/fstab

cd /www/htdocs/moodle

#resolve domain name to ip address
wwwrootval="http://$(dig +short $LoadbalancerFqdn):80/moodle"
DbIpAddress=$(dig +short $DbFqdn)

#Command line moodle installation
sed -i "s/Defaults    requiretty/#Defaults    requiretty/" /etc/sudoers

sudo -u apache /usr/local/php/bin/php admin/cli/install.php --chmod=770 --lang=en --wwwroot=$wwwrootval --dataroot='/www/moodledata' --dbhost=$DbIpAddress --dbpass=$dbpass --fullname=$FullNameOfSite --shortname=$ShortNameOfSite --adminuser=$MoodleAdminUser --adminpass=$MoodleAdminPass --adminemail=$MoodleAdminEmail --non-interactive --agree-license --allow-unstable || true

