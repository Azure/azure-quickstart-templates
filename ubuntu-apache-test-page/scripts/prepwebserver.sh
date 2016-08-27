#!/bin/bash

sudo apt-get update 
sudo apt-get install -y apache2
if [ "$1" = "true" ]; then
	sudo apt-get install -y php5
fi
echo $2 | sudo tee /var/www/html/$3