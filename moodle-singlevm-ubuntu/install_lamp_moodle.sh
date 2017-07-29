#!/bin/bash
apt-get -y update
apt-get -y install python-software-properties
add-apt-repository -y ppa:ondrej/php5-oldstable
apt-get -y update

# set up a silent install of MySQL
dbpass=$1
moodleVersion=$2
installOfficePlugins=$3

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

apt-get install unzip

# install Moodle
cd /var/www/html
curl -k --max-redirs 10 https://github.com/moodle/moodle/archive/$moodleVersion.zip -L -o moodle.zip
unzip moodle.zip
mv moodle-$moodleVersion moodle

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
    cp -r o365-moodle-$moodleVersion/* moodle
    
    cp -r o365-moodle-$moodleVersion/* moodle
    rm -rf o365-moodle-$moodleVersion
fi

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
