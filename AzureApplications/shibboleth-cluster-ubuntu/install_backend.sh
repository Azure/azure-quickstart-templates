
mysqlpassword=$1
mySqlUser=$2
mySqlPasswordForUser=$3

apt-get -y update
apt-get -y install apache2 openjdk-7-jdk tomcat7	

#install mysql
echo mysql-server mysql-server/root_password password $mysqlpassword | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password $mysqlpassword | sudo debconf-set-selections

apt-get -y install mysql-client mysql-server
apt-get	install libmysql-java

# Allow remote connection
sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

#create database
mysql -u root -p$mysqlpassword -e "create database idp_db";

#create table 
mysql -u root -p$mysqlpassword -e "use idp_db; create table StorageRecords(context varchar(255) NOT NULL,id varchar(255) NOT NULL,expires bigint(20) DEFAULT NULL,value longtext NOT NULL,version bigint(20) NOT NULL,PRIMARY KEY(context,id))";

#create user & grant all privileges
mysql -u root -p$mysqlpassword -e "create user $mySqlUser@'localhost' identified by '$mySqlPasswordForUser'";
mysql -u root -p$mysqlpassword -e "grant all privileges on *.* to $mySqlUser@'localhost'";

mysql -u root -p$mysqlpassword -e "create user $mySqlUser@'%' identified by '$mySqlPasswordForUser'";
mysql -u root -p$mysqlpassword -e "grant all privileges on *.* to $mySqlUser@'%'";

#restart mysql
service mysql restart 
