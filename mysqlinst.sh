

#script to install mysql

  sudo echo "installing mysql"
   sudo export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y install mysql-server


sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf 

echo "GRANT ALL ON *.* to root@'%';" >permission.sql
echo " flush privileges;">>permission.sql

echo "create database VehicleRental;" >>permission.sql
echo " exit">>permission.sql

sleep .5

sudo service mysql restart

sleep .5


mysql <permission.sql

