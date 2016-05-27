#!/bin/bash

REMOTEMYSQLIP=$1

apt-get -y update

#no password prompt while installing neo4j server
export DEBIAN_FRONTEND=noninteractive

#install php apache
apt-get -y install apache2 php5 libapache2-mod-php5

#php test file
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF