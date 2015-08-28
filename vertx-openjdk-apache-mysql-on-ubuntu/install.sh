#!/bin/bash

# Bash script to install Vert.x, OpenJDK 7, Apache and MySQL Server

# Set MySQL Server password
mysql_password="Passw0rd!"

# Set MySQL Server version to install
mysql_version="5.5"

# Set Vert.x filename to download. Change the name if you want to install a different version
vertx_filename="vert.x-2.1.5.zip"

# Install Vert.x, OpenJDK 7, and Apache
apt-get update
apt-get install unzip -y

# Default download location for Vert.x, change it if you want to use an alternative location
wget https://bintray.com/artifact/download/vertx/downloads/$vertx_filename
unzip $vertx_filename
apt-get install openjdk-7-jdk -y
apt-get install apache2-utils -y

# Install MySQL Server in non-interactive mode
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server-$mysql_version mysql-server/root_password password $mysql_password" | debconf-set-selections
echo "mysql-server-$mysql_version mysql-server/root_password_again password $mysql_password" | debconf-set-selections
apt-get install mysql-server -y

# Edit crontab to start MySQL Server service automatically on boot
crontab -l | { cat; echo "@reboot service mysql start"; } | crontab -