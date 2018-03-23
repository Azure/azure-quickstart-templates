#!/bin/sh

env ASSUME_ALWAYS_YES=YES pkg bootstrap
pkg update
pkg install -y nginx
pkg install -y php56
pkg install -y php56-pgsql-5.6.30 

echo 'nginx_enable="YES"' >> /etc/rc.conf
echo 'php_fpm_enable="YES"' >> /etc/rc.conf
echo 'ifconfig_hn1="DHCP"' >> /etc/rc.conf

ifconfig hn1 up

cp /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
cp ./backend_nginx.conf /usr/local/etc/nginx/nginx.conf

cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
cp /usr/local/etc/php-fpm.conf /usr/local/etc/php-fpm.conf.bak

sed -i -e 's/^listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g' /usr/local/etc/php-fpm.conf
sed -i -e 's/^;listen.owner = www/listen.owner = www/g' /usr/local/etc/php-fpm.conf
sed -i -e 's/^;listen.group = www/listen.group = www/g' /usr/local/etc/php-fpm.conf
sed -i -e 's/^;listen.mode = 0660/listen.mode = 0660/g' /usr/local/etc/php-fpm.conf
sed -i -e 's/^;events.mechanism = epoll/events.mechanism = kqueue/g' /usr/local/etc/php-fpm.conf
sed -i -e 's/^pm = dynamic/pm = static/g' /usr/local/etc/php-fpm.conf
sed -i -e 's/^pm.max_children = 5/pm.max_children = 240/g' /usr/local/etc/php-fpm.conf

re=`find / -name pgsql.so`
echo $re | sed 's./.\\/.g' > 1.txt
sed -i -e "s/^;   extension=modulename.extension/extension=`cat 1.txt`/g" /usr/local/etc/php.ini

echo "<?php" >> /usr/local/www/nginx/index.php
echo 'echo "Hello world!";' >> /usr/local/www/nginx/index.php
echo "?>" >> /usr/local/www/nginx/index.php

service nginx restart
service php-fpm restart

sed -i -e '/^[^#]/d' /etc/sysctl.conf
echo 'kern.ipc.soacceptqueue=4096' >> /etc/sysctl.conf
echo 'net.inet.tcp.msl=1000' >> /etc/sysctl.conf

echo "/sbin/reboot" | at + 1 minute
