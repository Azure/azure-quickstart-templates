#!/bin/bash

apt-get -y update

#no password prompt while installing neo4j server
export DEBIAN_FRONTEND=noninteractive

#install php apache
apt-get -y install apache2 

apt-get -y install php

apt-get -y install libapache2-mod-php

#install composer
#curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
#curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/var/www/html
#echo "starting to install composer"
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#php -r "if (hash_file('SHA384', 'composer-setup.php') === '070854512ef404f16bac87071a6db9fd9721da1684cd4589b1196c3faf71b9a2682e2311b36a5079825e155ac7ce150d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
#php composer-setup.php
#php -r "unlink('composer-setup.php');"
#echo "Composer is installed"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer 


#php test file
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF

#neo4j code test 
#creating the composer.json file which uses the neoclient
cat > /var/www/html/composer.json <<EOF
{
  "require": {
    "neoxygen/neoclient":"~2.1"
  }
}
EOF

#creating the neo4jtest php file
cat > /var/www/html/neo4jtest.php <<EOF
<?php

require_once 'vendor/autoload.php';

use Neoxygen\NeoClient\ClientBuilder;

\$client = ClientBuilder::create()
  ->addConnection('default', 'http', '10.0.0.10', 7474,true,'neo4j','neo4j')
  ->build();

if (!\$client) {
    die('Could not connect with neo4j database');
}
echo 'Connected sucessfully';
EOF

echo "everything installed successfully, lets install composer dependecies"

#composer install
cd /var/www/html
composer install
