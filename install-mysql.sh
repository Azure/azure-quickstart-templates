#!bin/bash
apt-get -y update

# set up a silent install of MySQL

export DEBIAN_FRONTEND=noninteractive

# install the LAMP stack
apt-get -y install mysql-server

# Create database & grant permission to root

echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" >permis.sql
echo "flush privileges;" >>permis.sql
echo "create database VehicleRental;" >>permis.sql
echo "exit"

#print

echo ****************************************


#restart mysql service

sudo service mysql restart

#change root passsword

mysqladmin -u root password Welcome123





# call permis.sql
mysql <permis.sql

#print

echo ****************************************


#change the bind address

sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf 


#restart mysql service

sudo service mysql restart


#print

echo ****************************************enddd




