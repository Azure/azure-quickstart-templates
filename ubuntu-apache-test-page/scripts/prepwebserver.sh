#!/bin/bash

sudo apt-get update 
sudo apt-get install -y apache2
if [ "$1" = "True" ]; then
	sudo apt-get install -y php5
	if [ "$3" = "index.php" ]; then
		sudo rm /var/www/html/index.html
	fi
	sudo service apache2 restart
fi
echo $2 | sudo tee /var/www/html/$3