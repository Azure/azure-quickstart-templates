#!/bin/bash

# install Apache and PHP (in a loop because a lot of installs happen
# on VM init, so won't be able to grab the dpkg lock immediately)
until apt-get -y update && apt-get -y install apache2 php5
do
  echo "Try again"
  sleep 2
done


# write some PHP; these scripts are downloaded beforehand as fileUris
cp index.php /var/www/html/
cp do_work.php /var/www/html/
rm /var/www/html/index.html
# restart Apache
apachectl restart
