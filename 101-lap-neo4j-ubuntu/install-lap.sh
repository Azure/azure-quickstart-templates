#!/bin/bash

apt-get -y update

#no password prompt while installing neo4j server
export DEBIAN_FRONTEND=noninteractive

#install php apache
apt-get -y install apache2 php5 libapache2-mod-php5

cd /var/www/html
#install composer
#curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

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

#composer install
#cd /var/www/html
#php composer.phar install
