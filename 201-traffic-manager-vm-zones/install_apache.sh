#!/bin/bash

# Cleanup
echo "* Cleanup..."
dpkg --configure -a
apt-get install -f

# Upgrade
echo "* Upgrade.."
apt-get -y update
apt-get -y dist-upgrade

# Install Apache2
echo "* Install Apache..."
apt-get remove apache*
apt-get -y install apache2

# Restart Apache
echo "* Restart Apache..."
apachectl restart

echo "* Finished!"