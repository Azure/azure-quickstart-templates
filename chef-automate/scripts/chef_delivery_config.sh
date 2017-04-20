sudo sed -i -e 's/false/"true"/g' /etc/delivery/delivery.rb
sudo delivery-ctl reconfigure
