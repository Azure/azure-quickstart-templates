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

# install iomad requirements
apt-get -y install graphviz aspell php5-pspell php5-curl php5-gd php5-intl php5-mysql php5-xmlrpc php5-ldap

# add port 8000 for admin access
perl -0777 -p -i -e 's/Listen 80/Listen 80\nListen 8080/ig' /etc/apache2/ports.conf
perl -0777 -p -i -e 's/\*:80/*:80 *:8080/g' /etc/apache2/sites-enabled/000-default.conf

# install iomad
cd /var/www/html
wget https://github.com/iomad/iomad/archive/IOMAD_29_STABLE.zip -O iomad.zip
apt-get install unzip
unzip iomad.zip
cp -r iomad-IOMAD_29_STABLE iomad

# make the iomad directory writable for owner
chown -R www-data iomad
chmod -R 770 iomad

# create moodledata directory
mkdir /var/www/moodledata
chown -R www-data /var/www/moodledata
chmod -R 770 /var/www/moodledata

# create cron entry
# It is scheduled for once per day. It can be changed as needed.
echo '0 0 * * * php /var/www/html/iomad/admin/cli/cron.php > /dev/null 2>&1' > cronjob
crontab cronjob

# restart Apache
apachectl restart

# mount share file on /var/www/moodledata
SharedStorageAccountName=$2
SharedAzureFileName=$3
SharedStorageAccountKey=$4
apt-get install cifs-utils
mount -t cifs //$SharedStorageAccountName.file.core.windows.net/$SharedAzureFileName /var/www/moodledata -o uid=$(id -u www-data),vers=2.1,username=$SharedStorageAccountName,password=$SharedStorageAccountKey,dir_mode=0770,file_mode=0770
	
#add mount to /etc/fstab to persist across reboots
chmod 770 /etc/fstab
echo "//$SharedStorageAccountName.file.core.windows.net/$SharedAzureFileName /var/www/moodledata cifs uid=$(id -u www-data),vers=3.0,username=$SharedStorageAccountName,password=$SharedStorageAccountKey,dir_mode=0770,file_mode=0770" >> /etc/fstab

LoadbalancerFqdn=$5
DbFqdn=$6
FullNameOfSite=$7
ShortNameOfSite=$8
IomadAdminUser=$9
IomadAdminPass=$10
IomadAdminEmail=$11

cd /var/www/html/iomad

#resolve domain name to ip address
wwwrootval="http://$(resolveip -s $LoadbalancerFqdn):80/iomad"
DbIpAddress=$(resolveip -s $DbFqdn)

#command line iomad installation
sudo -u www-data php admin/cli/install.php --chmod=770 --lang=en --wwwroot=$wwwrootval --dataroot='/var/www/moodledata' --dbhost=$DbIpAddress --dbpass=$dbpass --fullname=$FullNameOfSite --shortname=$ShortNameOfSite --adminuser=$IomadAdminUser --adminpass=$IomadAdminPass --adminemail=$IomadAdminEmail --non-interactive --agree-license --allow-unstable || true
