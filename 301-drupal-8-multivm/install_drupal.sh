#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# install Apache and PHP (in a loop because a lot of installs happen
# on VM init, so won't be able to grab the dpkg lock immediately)
# until apt-get -y update && apt-get -y install apache2 php5
# do
#   echo "Try again"
#   sleep 2
# done


# write some PHP; these scripts are downloaded beforehand as fileUris
# cp index.php /var/www/html/
# cp do_work.php /var/www/html/
# rm /var/www/html/index.html
# restart Apache
# apachectl restart


# Variables
DRUPAL_VERSION="8.1.1"
DRUPAL_ADMIN_USER="admin"
DRUPAL_ADMIN_PASSWORD=""
IS_FIRST_MEMBER=false

GLUSTER_FIRST_NODE_NAME=""
GLUSTER_VOLUME_NAME=""

MYSQL_FQDN=""
MYSQL_USER="admin"
MYSQL_PASSWORD=""
MYSQL_NEW_DB_NAME="drupaldb"  

help()
{
	echo "This script installs Drupal on the Ubuntu virtual machine image"
	echo "Options:"
	echo "		-d drupal version"
	echo "		-u drupal admin username "
	echo "		-p drupal admin password"
  echo "		-g gluster first node name"
  echo "		-v gluster file system volume name"
	echo "		-s mysql server fqdn"
	echo "		-n mysql root user name"
	echo "		-P mysql root user password"
  echo "		-k new drupal database name"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key 
	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/${LOGGING_KEY}/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

log "Begin execution of Drupal installation script extension on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi



# Parse script parameters
while getopts :d:u:p:g:v:s:n:P:k optname; do

	# Log input parameters (except the admin password) to facilitate troubleshooting
	if [ ! "$optname" == "p" ] && [ ! "$optname" == "P" ]; then
		log "Option $optname set with value ${OPTARG}"
	fi
  
	case $optname in
	d) # drupal version
		DRUPAL_VERSION=${OPTARG}
		;;
	u) # drupal admin username
		DRUPAL_ADMIN_USER=${OPTARG}
		;;
	p) # drupal admin password
		DRUPAL_ADMIN_PASSWORD=${OPTARG}
		;;	
  g) # gluster first node name
		GLUSTER_FIRST_NODE_NAME=${OPTARG}
		;;
  v) # gluster file system volume name
		GLUSTER_VOLUME_NAME=${OPTARG}
		;;
	s) # mysql server fqdn
		MYSQL_FQDN=${OPTARG}
		;;	
	n) # mysql root user name
		MYSQL_USER=${OPTARG}
		;;		
	P) # mysql root user password
		MYSQL_PASSWORD=${OPTARG}
		;;
	k) # new drupal database name
		MYSQL_NEW_DB_NAME=${OPTARG}
		;;    
	f) # first drupal node indicator
		IS_FIRST_MEMBER=true
		;;	
	\?) # Unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done

# Validate parameters
if [ "$GLUSTER_FIRST_NODE_NAME" == "" ] || [ "$GLUSTER_VOLUME_NAME" == "" ] || [ "$MYSQL_FQDN" == "" ] || [ "$MYSQL_USER" == "" ] || [ "$MYSQL_PASSWORD" == "" ];
then
    log "Script executed without required parameters"
    echo "You must provide all required parameters." >&2
    exit 3
fi

install_required_packages()
{
  # Install required packages
  echo "installing required packages"
  add-apt-repository ppa:gluster/glusterfs-3.7 -y
  until apt-get -y update && apt-get -y install apache2 php5 php5-gd php5-mysql glusterfs-client mysql-client git 
  do
    echo "Still installing required packages"
    sleep 2
  done
  
  # Install Drush
  php -r "readfile('http://files.drush.org/drush.phar');" > drush
  chmod +x drush
  mv drush /usr/local/bin
  
  # Install Composer
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
}

configure_prequisites()
{
 echo "configuring prerquisites"

 # uncomments lines below to display errors
   #  sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
   #  sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/cli/php.ini
 
 # Set overrides on in apache2.conf
 sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
 
 # override  web root
 sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/drupal/g' /etc/apache2/sites-enabled/000-default.conf
 
 a2enmod rewrite ssl
 service apache2 restart
 
 # create gluster mount point
 mkdir -p /data
 
 # mount gluster files system
 mount -t glusterfs $GLUSTER_FIRST_NODE_NAME:/$GLUSTER_VOLUME_NAME /data
 
 # check if this is the first drupal node based on host name, and existance of files directory, and set IS_FIRST_MEMBER
 hname = $HOSTNAME
 lastchar = ${hname: -1}
if [ ! -d /data/files ] && [ "$lastchar" = "0" ]; then
  IS_FIRST_MEMBER=true
fi
 
 # if first drupal node then create /data/files directory on glusterfs
 if [ "$IS_FIRST_MEMBER" = true ]; then
      mkdir -p /data/files
 fi
 
 
}

install_drupal()
{
 echo "installing drupal"
 
 composer create-project drupal/drupal drupal8-site $DRUPAL_VERSION --keep-vcs
 cd drupal8-site/
 composer install
 cd ..
 mv drupal8-site /var/www/html/drupal
 cd /var/www/html/drupal/sites/default
 
 ln -s /data/files files
 
 if [ "$IS_FIRST_MEMBER" = true ]; then
     cp default.settings.php /data/settings.php
     cp default.services.yml /data/services.yml
 else
     while [ ! -f /data/services.yml ] ;
     do
      sleep 2
     done
 fi
 
 ln -s /data/settings.php ./settings.php
 ln -s /data/services.yml ./services.yml
 chmod -R 777 /var/www/html/drupal/sites/default/files/
 chmod -R 755 /var/www/html/drupal/sites/default/
 chmod 777 /var/www/html/drupal/sites/default/settings.php
 chmod 777 /var/www/html/drupal/sites/default/services.yml
 
}

install_drupal_site()
{
 echo "creating drupal site"
 cd /var/www/html/drupal/
 
 drush site-install --site-name="drupal-site" --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_FQDN/$MYSQL_NEW_DB_NAME --account-name=$DRUPAL_ADMIN_USER --account-pass=$DRUPAL_ADMIN_PASSWORD -y
}

secure_files()
{
 chmod 444 /var/www/html/drupal/sites/default/settings.php
 chmod 444 /var/www/html/drupal/sites/default/services.yml
 service apache2 restart
}

# Step 1
install_required_packages

# Step 2
configure_prequisites

# Step 3
install_drupal

# Step 4
if [ "$IS_FIRST_MEMBER" = true ]; then
  install_drupal_site
fi

# Step 5
secure_files