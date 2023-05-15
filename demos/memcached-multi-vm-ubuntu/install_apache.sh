#!/bin/bash

# Get passed in parameters
numberOfMemcachedInstances=$1
subnetMemcachedPrefix=$2

# Create simple python script to iterate over the IPs skipping first 3
echo "c=$numberOfMemcachedInstances" > p.py
echo "ip='$subnetMemcachedPrefix'" >> p.py
echo "octets=ip.split('/')[0].split('.')" >> p.py
echo "octets[3]=str(int(octets[3])+3)" >> p.py
echo "s=[]" >> p.py
echo "for i in range(0,c):" >> p.py
echo "  octets[3]=str(int(octets[3])+1)" >> p.py
echo "  s.append('.'.join(octets))" >> p.py
echo "print(','.join(s))" >> p.py

# Get comma delimited list of servers
servers=$(python ./p.py)

# Get today's date into YYYYMMDD format
now=$(date +"%Y%m%d")

echo "Installing apache $now, numberOfMemcachedInstances=$numberOfMemcachedInstances, subnetMemcachedPrefix=$subnetMemcachedPrefix, servers=$servers" >> /var/log/apache_install.log

# Re-synchronize the package index files from their sources. An update should always be performed before an upgrade.
apt-get -y update

# Install apache, php5, and php5-memcached extension
apt-get -y install apache2 php5 php5-memcached

# Delete Apache index page
rm /var/www/html/index.html

# Download cache_test.php page
wget -O /var/www/html/index.php https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/memcached-multi-vm-ubuntu/cache_test.php

# Replace the placeholder with the string of comma delimited memcached server IPs that was passed to this script as a parameter
sed -i "s/{COMMA_DELIMITED_SERVERS_LIST}/$servers/g" /var/www/html/index.php

# restart Apache
apachectl restart
