sudo mv /var/lib/waagent/Microsoft.Azure.Extensions.CustomScript-2.0.0/download/0/app.js /opt/app.js

# Install updates
sudo apt-get -y update

# Modified tcp keepalive according to https://docs.mongodb.org/ecosystem/platforms/windows-azure/
sudo bash -c "sudo echo net.ipv4.tcp_keepalive_time = 120 >> /etc/sysctl.conf"

sudo apt-get -y install nodejs
sudo apt-get -y install npm
sudo apt-get install -y mongodb-org







