#/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y apache2

echo "You're connected to $(hostname)" | sudo tee /var/www/html/index.html