#!bin/bash
apt-get -y update

# set up a silent install of MySQL
$dbpass="welcome123"

export DEBIAN_FRONTEND=noninteractive
echo mysql-server-5.6 mysql-server/root_password password $dbpass | debconf-set-selections
echo mysql-server-5.6 mysql-server/root_password_again password $dbpass | debconf-set-selections

# install the LAMP stack
apt-get -y install mysql-server

#change the bind address

sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf 


# Create database & grant permission to root

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" >permis.sql
echo "flush privileges;">>permis.sql
echo "create database VehicleRental;" >>permis.sql
echo "exit"

#restart mysql service

sudo service mysql restart



