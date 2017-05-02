#!/bin/bash
apt-get -y update
apt-get -y install python-software-properties
add-apt-repository -y ppa:ondrej/php5-oldstable
apt-get -y update

# set up a silent install of MySQL
dbpass=$1
SharedStorageAccountName=$2
SharedAzureFileName=$3
FullNameOfSite=$4
ShortNameOfSite=$5
MoodleAdminUser=$6
MoodleAdminPass=$7
MoodleAdminEmail=$8
moodleVersion=$9
installOfficePlugins=$10
SharedStorageAccountKey=$11
LoadbalancerFqdn=$12
DbFqdn=$13

export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.6 mysql-server/root_password password $dbpass | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $dbpass | debconf-set-selections

# install the LAMP stack
apt-get -y install apache2 mysql-client mysql-server php5

# install moodle requirements
apt-get -y install graphviz aspell php5-pspell php5-curl php5-gd php5-intl php5-mysql php5-xmlrpc php5-ldap

# add port 8000 for admin access
perl -0777 -p -i -e 's/Listen 80/Listen 80\nListen 8080/ig' /etc/apache2/ports.conf
perl -0777 -p -i -e 's/\*:80/*:80 *:8080/g' /etc/apache2/sites-enabled/000-default.conf

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
    
    #Copy office plugins to moodle and remove office unzipped folder
   
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

# restart Apache
apachectl restart

# mount share file on /var/www/moodledata
apt-get install cifs-utils
mount -t cifs //$SharedStorageAccountName.file.core.windows.net/$SharedAzureFileName /var/www/moodledata -o uid=$(id -u www-data),vers=2.1,username=$SharedStorageAccountName,password=$SharedStorageAccountKey,dir_mode=0770,file_mode=0770
	
#add mount to /etc/fstab to persist across reboots
chmod 770 /etc/fstab
echo "//$SharedStorageAccountName.file.core.windows.net/$SharedAzureFileName /var/www/moodledata cifs uid=$(id -u www-data),vers=3.0,username=$SharedStorageAccountName,password=$SharedStorageAccountKey,dir_mode=0770,file_mode=0770" >> /etc/fstab

cd /var/www/html/moodle

#resolve domain name to ip address
wwwrootval="http://$(resolveip -s $LoadbalancerFqdn):80/moodle"
DbIpAddress=$(resolveip -s $DbFqdn)

#command line moodle installation
sudo -u www-data php admin/cli/install.php --chmod=770 --lang=en --wwwroot=$wwwrootval --dataroot='/var/www/moodledata' --dbhost=$DbIpAddress --dbpass=$dbpass --fullname=$FullNameOfSite --shortname=$ShortNameOfSite --adminuser=$MoodleAdminUser --adminpass=$MoodleAdminPass --adminemail=$MoodleAdminEmail --non-interactive --agree-license --allow-unstable || true
