#!/bin/bash
# wait for Linux Diagnostic Extension to complete
for i in {1..60}; do
  if [ -e /var/lib/cloud/instance/boot-finished ]
  then
    echo "the provisioning has complete"
    break
  fi
  sleep 10
done

# install Apache and PHP
apt-get -y update
apt-get -y install apache2 php5

# write some PHP
cd /var/www/html
wget https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vmss-lapstack-autoscale/index.php
wget https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vmss-lapstack-autoscale/do_work.php
rm /var/www/html/index.html
# restart Apache
apachectl restart
