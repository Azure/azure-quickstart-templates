#!/bin/bash
dbpass=$1
SharedStorageAccountName=$2
SharedAzureFileName=$3
SharedStorageAccountKey=$4

# Setting homepath to home to avoid npm runtime exeception
superuser=`awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd`
export HOME=/home/$superuser 

# Installing development tools
yum install -y make bison bzr cmake gcc gcc-c++ ncurses-devel perl 
yum -y install epel-release
yum install -y 'perl(Data::Dumper)'

# Install azure cli and dependent packages
yum install -y nodejs 
yum install -y npm
npm install -g azure-cli

# Create Azure file share that will be used by front end VM's for moodledata directory
azure storage share create $SharedAzureFileName -a $SharedStorageAccountName -k $SharedStorageAccountKey

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

# set up a silent install of MySQL

mkdir /opt/setup
cd /opt/setup

# Download MySql
wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.14.tar.gz

tar xvzf mysql-5.6.14.tar.gz

# MySql
cd /opt/setup/mysql-5.6.14/

# Add mysql user and group
groupadd mysql
useradd -g mysql -s /bin/false mysql

CC='gcc' CXX='g++'
export CC CXX
mkdir /usr/local/mysql  
mkdir /usr/local/mysql/data

# Build and compile mysql source code
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE_ENGINE:BOOL=ON
make
make install

# Added mysql user permission to mysql installation folder 
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

cd /etc/init.d
/etc/init.d/mysql.server start

# Enable barracuda table format
echo 'innodb_file_per_table = 1' >> /etc/my.cnf
echo 'innodb_file_format = barracuda' >> /etc/my.cnf

# Restart mysql
/etc/init.d/mysql.server restart

# Allow remote connection
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /usr/local/mysql/my.cnf
iptables -A INPUT -i eth0  -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT

# Create moodle database
/usr/local/mysql/bin/mysql -u root -e  "use mysql;CREATE DATABASE moodle DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci; FLUSH PRIVILEGES; UPDATE user SET password=PASSWORD('$dbpass') WHERE User='root';"
/usr/local/mysql/bin/mysql -u root  -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$dbpass' WITH GRANT OPTION; FLUSH PRIVILEGES;";

# Restart mysql
/etc/init.d/mysql.server restart
