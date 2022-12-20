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


# Variables - Initialize default values
DRUPAL_VERSION="8.1.1"
DRUPAL_ADMIN_USER="admin"
DRUPAL_ADMIN_PASSWORD=""
IS_FIRST_MEMBER=false

GLUSTER_FIRST_NODE_NAME=""
GLUSTER_VOLUME_NAME=""

MYSQL_FQDN=""
EXISTING_MYSQL_FQDN=""
NEW_MYSQL_FQDN=""

MYSQL_USER="admin"
EXISTING_MYSQL_USER="admin"
NEW_MYSQL_USER="admin"

MYSQL_PASSWORD=""
MYSQL_NEW_DB_NAME="drupaldb"

CREATE_NEW_MYSQL_SERVER="no"

help()
{
	echo "This script installs Drupal on the Ubuntu virtual machine image"
	echo "Options:"
	echo "		-d drupal version"
	echo "		-u drupal admin username "
	echo "		-p drupal admin password"
  echo "		-g gluster first node name"
  echo "		-v gluster file system volume name"
	echo "		-s Existing mysql server fqdn"
	echo "		-n mysql root user name"
	echo "		-P mysql root user password"
  echo "		-k new drupal database name"
  echo "		-z if Yes connect to newly created mysql server, else connect to existing mysql server"
  echo "		-S FQDN of the newly created MySQL Server"
}

log()
{
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
while getopts :d:u:p:g:v:s:n:P:k:z:S:h optname; do

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
		EXISTING_MYSQL_FQDN=${OPTARG}
		;;
	n) # mysql root user name
		EXISTING_MYSQL_USER=${OPTARG}
		;;
	P) # mysql root user password
		MYSQL_PASSWORD=${OPTARG}
		;;
	k) # new drupal database name
		MYSQL_NEW_DB_NAME=${OPTARG}
		;;
	z) # "yes" or "no" value indicating whether new mysql server is to be used ("yes") or existing  mysql server is to be used ("no")
		CREATE_NEW_MYSQL_SERVER=${OPTARG}
		;;
	S) # FQDN of the newly created mysql server
		NEW_MYSQL_FQDN=${OPTARG}
		;;
	h) # new drupal database name
		;;

	\?) # Unrecognized option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done


#TODO: everything after this needs to be fixed
echo "installing drupal $HOSTNAME" >> /mnt/azurefiles-drupal/$HOSTNAME.txt
exit

# Validate parameters - GLUSTER params have been removed
if [ "$GLUSTER_FIRST_NODE_NAME" == "" ] || [ "$GLUSTER_VOLUME_NAME" == "" ] || [ "$MYSQL_PASSWORD" == "" ];
then
    log "Script executed without required parameters"
    echo "You must provide all required parameters." >&2
    exit 3
fi


# set mysql server FQDN to be used (existing or new), and the mysql username to used (existing or "admin")
if [ "$CREATE_NEW_MYSQL_SERVER" == "no" ]; then
  MYSQL_FQDN=$EXISTING_MYSQL_FQDN
  MYSQL_USER=$EXISTING_MYSQL_USER
else
  MYSQL_FQDN=$NEW_MYSQL_FQDN
  MYSQL_USER="admin"
fi

install_required_packages()
{
  # Install required packages
  echo "installing required packages"
  add-apt-repository ppa:gluster/glusterfs-3.7 -y
  until apt-get -y update && apt-get -y install apache2 php5 php5-gd php5-mysql glusterfs-client mysql-client git
  do
  echo "installing required packages....."
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

 # Check if this is the first drupal node based on existance of files directory and lockfile, and set IS_FIRST_MEMBER
 # The first member node will be the only one which will install the drupal site using drush site-install.
 # Other member nodes will wait for the drupal site to install
if [ ! -d /data/files ] && [ ! -f /data/flock.lock ]; then
  touch /data/flock.lock
  echo "first drupal node :" >> /data/flock.lock
  echo $(hostname) >> /data/flock.lock
  IS_FIRST_MEMBER=true
  echo "lock created: Now acting as first drupal node"
fi

 # if first drupal node then create /data/files directory on glusterfs
 if [ "$IS_FIRST_MEMBER" = true ]; then
      mkdir -p /data/files
	  echo "creating files folder on shared mount.."
 fi


}

install_drupal()
{
 echo "installing drupal"

 # create drupal project will given drupal version
 composer create-project drupal/drupal drupal8-site $DRUPAL_VERSION --keep-vcs
 cd drupal8-site/
 composer install
 cd ..

 # Move the drupal directory under html folder
 mv drupal8-site /var/www/html/drupal

 # Navigate to the drupal default directory
 cd /var/www/html/drupal/sites/default

 # Create Sym Link to the files folder
 ln -s /data/files files

 if [ "$IS_FIRST_MEMBER" = true ]; then
     cp default.settings.php /data/settings.php
     cp default.services.yml /data/services.yml
	 echo "copied settings.php and services.yml to shared mount..."
	 echo "copied settings.php and services.yml to shared mount..." >> /data/flock.lock
 else
     while [ ! -d /data/files/js ] ;
     do
      sleep 30
	  echo "Sleeping, waiting for node 1 to create drupal site"
     done
	 echo "Directory created, exiting sleep loop.."
 fi

 ln -s /data/settings.php ./settings.php
 ln -s /data/services.yml ./services.yml
 echo "Created Sym links..."

 if [ "$IS_FIRST_MEMBER" = true ];  then
   chmod -R 777 /var/www/html/drupal/sites/default/files/
   chmod -R 755 /var/www/html/drupal/sites/default/
   chmod 777 /var/www/html/drupal/sites/default/settings.php
   chmod 777 /var/www/html/drupal/sites/default/services.yml
   echo "modified permisssions on files for installation..."
fi


}

install_drupal_site()
{
 echo "creating drupal site"
 cd /var/www/html/drupal/

 echo "before execution of drush site-install command" >> /data/flock.lock

drush site-install --site-name="drupal-site" --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_FQDN/$MYSQL_NEW_DB_NAME --account-name=$DRUPAL_ADMIN_USER --account-pass=$DRUPAL_ADMIN_PASSWORD -y

wget localhost

chmod -R 777 /var/www/html/drupal/sites/default/files/
 echo "drupal site created...."
 echo "drupal site created...."  >> /data/flock.lock
}

secure_files()
{
 chmod 444 /var/www/html/drupal/sites/default/settings.php
 chmod 444 /var/www/html/drupal/sites/default/services.yml

 # Set lock file to readonly.
 chmod 444 /data/flock.loc

 echo "Files secured"
}

restart_webserver()
{
service apache2 restart
echo "Web server restarted...."
}



# Step 1
install_required_packages

# Step 2
configure_prequisites

# Step 3
install_drupal

# Step 4
# if [ "$IS_FIRST_MEMBER" = true ] || [ ! -f /data/startDrupalCreation ];  then

if [ "$IS_FIRST_MEMBER" = true ];  then
  echo "Invoking Drupal Site Installation routine...."
  install_drupal_site

fi

# Step 5
if [ "$IS_FIRST_MEMBER" = true ];  then
	secure_files
fi

# Step 6
restart_webserver
