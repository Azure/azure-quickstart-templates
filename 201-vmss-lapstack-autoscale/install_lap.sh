#!/bin/bash

# install Apache and PHP (in a loop because a lot of installs happen
# on VM init, so won't be able to grab the dpkg lock immediately)
until apt-get -y update && apt-get -y install apache2 php5
do
  echo "Try again"
  sleep 2
done




# write some PHP
cd /var/www/html
wget https://raw.githubusercontent.com/gatneil/azure-quickstart-templates/lapstack_fix/201-vmss-lapstack-autoscale/index.php
wget https://raw.githubusercontent.com/gatneil/azure-quickstart-templates/lapstack_fix/201-vmss-lapstack-autoscale/do_work.php
rm /var/www/html/index.html
# restart Apache
apachectl restart
