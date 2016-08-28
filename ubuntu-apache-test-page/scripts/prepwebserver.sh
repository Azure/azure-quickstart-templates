#!/bin/bash

sudo apt-get update 
sudo apt-get install -y apache2
if [ "$1" = "True" ]; then
	if [ "$4" = "16.04.0-LTS" ]; then
		sudo apt-get install -y libapache2-mod-php
	else
		sudo apt-get install -y php5
	fi
	if [ "$3" = "index.php" ]; then
		sudo rm /var/www/html/index.html
	fi
	sudo service apache2 restart
fi
echo $2 | sudo tee /var/www/html/$3
