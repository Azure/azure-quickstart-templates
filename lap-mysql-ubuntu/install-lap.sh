#!/bin/bash

REMOTEMYSQLIP=$1

apt-get -y update

#no password prompt while installing mysql server
export DEBIAN_FRONTEND=noninteractive

#install php mysql apache
apt-get -y install apache2 php5 libapache2-mod-php5 mysql-server libapache2-mod-auth-mysql php5-mysql

#php test file
cat > /var/www/html/info.php <<EOF
<?php
phpinfo();
?>
EOF

#mysql connection test file
cat > /var/www/html/mysql.php <<EOF
<?php
\$link = mysql_connect('localhost', 'root', '');
if (!\$link) {
    die('Could not connect:' . mysql_error());
}
echo 'Connected sucessfully';
?>
EOF

cat > /var/www/html/remotemysql.php <<EOF
<?php
\$link = mysql_connect('$REMOTEMYSQLIP', 'root', '');
if (!\$link) {
    die('Could not connect:' . mysql_error());
}
echo 'Connected sucessfully';
?>
EOF
