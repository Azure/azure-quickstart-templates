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

# add port 8000 for admin access
sudo perl -0777 -p -i -e 's/Listen 80/Listen 80\nListen 8080/ig' /etc/apache2/ports.conf
sudo perl -0777 -p -i -e 's/\*:80/*:80 *:8080/g' /etc/apache2/sites-enabled/000-default.conf

# install Moodle
cd /var/www/html
wget https://download.moodle.org/download.php/direct/stable29/moodle-2.9.2.zip -O moodle.zip
apt-get install unzip
unzip moodle.zip

# make the moodle directory writable for owner
chown -R www-data moodle
chmod -R 0755 moodle

# # mount moodledata disk
# # The ARM script only mounts a single data disk.  It is safe 
# # to assume that on a new VM, this data disk is located at /dev/sdc.

# # If you have a more complicated setup, then do examine what this
# # script is doing and modify accordingly.

# # create a partition table for the disk
# parted -s /dev/sdc mklabel msdos

# # create a single large partition
# parted -s /dev/sdc mkpart primary ext4 0\% 100\%

# # install the file system
# mkfs.ext4 /dev/sdc1

# # create the mount point
# mkdir -p /moodledata

# # mount the disk
# mount /dev/sdc1 /moodledata/

# # premissions
# chown -R www-data /moodledata
# chmod -R 777 /moodledata

# # add mount to /etc/fstab to persist across reboots
# echo "/dev/sdc1    /moodledata/    ext4    defaults 0 0" >> /etc/fstab

# TODO: create cron entry
# * * * * *    /usr/bin/php /path/to/moodle/admin/cli/cron.php >/dev/null

# restart Apache
apachectl restart
