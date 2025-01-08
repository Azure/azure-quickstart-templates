#!/bin/bash

cd /opt/

echo "PHABRICATOR UBUNTU INSTALL SCRIPT";
echo "This script will install Phabricator and all of its core dependencies.";
echo "Run it from the directory you want to install into.";
echo

ROOT=`pwd`
echo "Phabricator will be installed to: ${ROOT}.";

echo "Testing sudo..."
sudo true
if [ $? -ne 0 ]
then
  echo "ERROR: You must be able to sudo to run this script.";
  exit 1;
fi;

echo "Installing dependencies: git, apache, mysql, php...";
echo

set +x

sudo apt-get -qq update
sudo apt-get -y install git apache2 dpkg-dev php7.0 php7.0-mysql php7.0-gd php7.0-dev php7.0-curl php7.0-cli php7.0-json libapache2-mod-php7.0 php7.0-mbstring

# Enable mod_rewrite
sudo a2enmod rewrite

if [ ! -e libphutil ]
then
  git clone https://github.com/phacility/libphutil.git
else
  (cd libphutil && git pull --rebase)
fi

if [ ! -e arcanist ]
then
  git clone https://github.com/phacility/arcanist.git
else
  (cd arcanist && git pull --rebase)
fi

if [ ! -e phabricator ]
then
  git clone https://github.com/phacility/phabricator.git
else
  (cd phabricator && git pull --rebase)
fi

sudo echo 'mysql-server mysql-server/root_password password pass@word1' | debconf-set-selections
sudo echo 'mysql-server mysql-server/root_password_again password pass@word1' | debconf-set-selections
sudo apt-get -y install mysql-server


sudo touch /etc/apache2/sites-available/phabricator.conf

sudo echo "<VirtualHost *>" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "  ServerName $1" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "  DocumentRoot /opt/phabricator/webroot" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "  RewriteEngine on" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "  RewriteRule ^/rsrc/(.*)     -                       [L,QSA]" >> /etc/apache2/sites-available/phabricator.conf
sudo echo "  RewriteRule ^/favicon.ico   -                       [L,QSA]" >> /etc/apache2/sites-available/phabricator.conf
sudo echo '  RewriteRule ^(.*)$          /index.php?__path__=$1  [B,L,QSA]' >> /etc/apache2/sites-available/phabricator.conf
sudo echo "</VirtualHost>" >> /etc/apache2/sites-available/phabricator.conf

sudo echo '<Directory "/opt/phabricator/webroot">' >> /etc/apache2/apache2.conf
sudo echo '  Require all granted' >> /etc/apache2/apache2.conf
sudo echo "</Directory>" >> /etc/apache2/apache2.conf

sudo a2dissite 000-default.conf
sudo a2ensite phabricator.conf
sudo service apache2 reload


sudo /opt/phabricator/bin/config set mysql.user root
sudo /opt/phabricator/bin/config set mysql.pass pass@word1

sudo /opt/phabricator/bin/storage upgrade --force

echo
echo "Install probably worked mostly correctly. Continue with the 'Configuration Guide':";
echo
echo "    https://secure.phabricator.com/book/phabricator/article/configuration_guide/";
echo
echo "You can delete any php5-* stuff that's left over in this directory if you want.";
