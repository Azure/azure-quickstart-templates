#!/bin/bash
# wait for Linux Diagnostic Extension to complete
while ( ! grep "Start mdsd" /var/log/azure/Microsoft.OSTCExtensions.LinuxDiagnostic/2.1.5/extension.log); do
    sleep 5
done

# install Apache and PHP
apt-get -y update
apt-get -y install apache2 php5

# write some PHP
cd /var/www/html
wget https://raw.githubusercontent.com/madhana/azure-quickstart-templates/master/201-vmss-lap-autoscale/index.php
wget https://raw.githubusercontent.com/madhana/azure-quickstart-templates/master/201-vmss-lap-autoscale/do_work.php
rm /var/www/html/index.html
# restart Apache
apachectl restart