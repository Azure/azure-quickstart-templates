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

# Script parameters and their defaults
SERVICE_USERNAME="nagios"
ADMIN_USERNAME="nagios"
ADMIN_PASSWORD="Zk8LgLeR4ZimcgipTNzJKUBXVABDpYH63B9bzMbh2uRm8gYwRFPhSz8AvYspz3vs" # Don't worry, this is not the actual password. The real password will be supplied by the ARM template.
CORE_VERSION="4.0.8"
PLUGINS_VERSION="2.0.3"
LOGGING_KEY="[logging-key]"

########################################################
# This script will install and configure Nagios Core
########################################################
help()
{
	echo "This script installs and configures Nagios Core on the Ubuntu virtual machine image"
	echo "Available parameters:"
	echo "-u Admin_User_Name"
	echo "-p Admin_User_Password"
	echo "-v Core_Package_Version"
}

log()
{
	# If you want to enable this logging add a un-comment the line below and add your account key
	#curl -X POST -H "content-type:text/plain" --data-binary "$(date) | ${HOSTNAME} | $1" https://logs-01.loggly.com/inputs/${LOGGING_KEY}/tag/redis-extension,${HOSTNAME}
	echo "$1"
}

log "Begin execution of Nagios Core installation script on ${HOSTNAME}"

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

# Parse script parameters
while getopts ":u:p:v:h" optname; do
  log "Option $optname set with value ${OPTARG}"

  case "$optname" in
	u) # Admin user name
		ADMIN_USERNAME=${OPTARG}
		;;
	p) # Admin user name
		ADMIN_PASSWORD=${OPTARG}
		;;
	v) # Core package version
		CORE_VERSION=${OPTARG}
		;;
    h)  # Helpful hints
		help
		exit 2
		;;
    \?) # Unrecognised option - show help
		echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
		help
		exit 2
		;;
  esac
done

# Install essentials
log "Installing system essentials..."
apt-get -y update

#  Install Apache (a pre-requisite for Nagios)
log "Installing Apache..."
apt-get -y install apache2

# Install MySQL (a pre-requisite for Nagios)
log "Installing MySQL..."
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server mysql-client
mysqladmin -u root password $ADMIN_PASSWORD

# Install PHP (a pre-requisite for Nagios)
log "Installing PHP..."
apt-get -y install php5 php5-mysql libapache2-mod-php5

# Install LAMP prerequisites
log "Installing other LAMP prerequisites..."
apt-get -y install build-essential libgd2-xpm-dev apache2-utils

# Restart apache2 service
log "Restarting apache2 service..."
service apache2 restart

# Create a new Nagios user account and give it a password
log "Creating and configuring the Nagios service user account..."
useradd -m $SERVICE_USERNAME
echo '$SERVICE_USERNAME:$ADMIN_PASSWORD' | chpasswd -m

# Create a new nagcmd group for allowing external commands to be submitted through the web interface. Add both the nagios user and the apache user to the group.
log "Creating and configuring the Nagios security group for external access..."
groupadd nagcmd
usermod -a -G nagcmd $SERVICE_USERNAME
usermod -a -G nagcmd www-data

# Download Nagios and plugins
log "Downloading Nagios package and plugins..."
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-$CORE_VERSION.tar.gz
wget http://nagios-plugins.org/download/nagios-plugins-$PLUGINS_VERSION.tar.gz

# Install Nagios and plugins
log "Configuring Nagios packages..."
tar xzf nagios-$CORE_VERSION.tar.gz
cd nagios-$CORE_VERSION
./configure --with-command-group=nagcmd

# Compile and install nagios modules
log "Compiling Nagios packages..."
make all
make install
make install-init
make install-config
make install-commandmode

# Install Nagios Web interface
log "Installing the Nagios Web interface..."
/usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-enabled/nagios.conf

# Create a nagios admin account for logging into the Nagios web interface.
log "Creating the admin account for logging into the Nagios web interface..."
htpasswd -cb /usr/local/nagios/etc/htpasswd.users $ADMIN_USERNAME $ADMIN_PASSWORD

# Install Nagios plugins
log "Configuring Nagios plugins..."
tar xzf nagios-plugins-$PLUGINS_VERSION.tar.gz
cd nagios-plugins-$PLUGINS_VERSION
./configure --with-nagios-user=nagios --with-nagios-group=nagios

log "Compiling Nagios plugins..."
make
make install

# Enable Apache’s rewrite and cgi modules
log "Enabling Apache modules..."
a2enmod rewrite
a2enmod cgi
service apache2 restart

# Check nagios.conf file for any syntax errors
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

# Start nagios service and make it to start automatically on every boot
log "Starting the Nagios service..."
service nagios start
ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios

log "Nagios Core was installed successfully"
