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
	echo "		-f first drupal node indicator"	
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
while getopts :d:u:p:g:v:s:n:P:k:f optname; do

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
until apt-get -y update && apt-get -y install apache2 php5
do
  echo "Try again"
  sleep 2
done
}

configure_prequisites()
{
  
}

install_drupal
{
  
}

create_drupal_site
{
  
}

# Step 1
install_required_packages

# Step 2
configure_prequisites

# Step 3
install_drupal

# Step 4
create_drupal_site