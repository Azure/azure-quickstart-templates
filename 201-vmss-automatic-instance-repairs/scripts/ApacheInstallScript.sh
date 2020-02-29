#!/bin/bash

apt-get -f -y autoremove
apt-get -y update

# install Apache2
apt-get -f -y install apache2 

# write some HTML
echo \<center\>\<h1\>Hello World\</h1\>\<br/\>\</center\> > /var/www/html/hello.html

# restart Apache
apachectl restart