mysql_pass=$1
database_name=$2
sudo apt-get update
echo "Installing Apache"
sudo apt-get --yes install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo apt-get --yes install python-software-properties
echo "Installing Mariadb"
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo apt-get --yes install mariadb-server mariadb-client
sudo mysql_secure_installation << EOF

y
$mysql_pass
$mysql_pass
y
y
y
y
EOF
echo "Create database named openScholar"
sudo mysql -u root -p$mysql_pass -e "create database $database_name";
sudo mysql -u root -p$mysql_pass -e "grant all privileges on $database_name.* to 'root'@'localhost' identified by '$mysql_pass';";
sudo mysql -u root -p$mysql_pass -e "flush privileges;";
echo "Installing the php version 5.6"
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get --yes upgrade
sudo apt-get --yes install php5.6
echo "Installing php extensions for drupal"
sudo apt-get --yes install php5.6-gd php5.6-mysql php5.6-dom php5.6-cli php5.6-json php5.6-common php5.6-mbstring php5.6-opcache php5.6-readline
sudo systemctl start apache2
cd /var/www
echo "Download the openscholar drupal profile, increase memory enable mod rewrite and change in apache config for htaccess"
sudo su <<EOF
cd html
wget https://osprojectsite.org/files/osorg2/files/drupal-openscholar-7.x-3.90.1.tar.gz
tar -zxvf drupal-openscholar-7.x-3.90.1.tar.gz
cd sites/default
mkdir files
cp default.settings.php settings.php
chmod -R 777 *
sudo a2enmod rewrite
sudo systemctl restart apache2
cd /etc/php/5.6/apache2/
sed -e "s/memory_limit = 128M/memory_limit = 512M/" php.ini > php_new.ini
mv php_new.ini php.ini
cd /var/www/html
mv index.html old.html
cd /etc/apache2
sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' apache2.conf > apache2_new.conf
mv apache2_new.conf apache2.conf
sudo systemctl restart apache2
cd /var/www/html/profiles/openscholar/modules/contrib/oembed/
wget https://www.drupal.org/files/oembed-2021015-1.patch
patch -p1 < oembed-2021015-1.patch
EOF
