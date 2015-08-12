sudo apt-get -y update
sudo apt-get -y upgrade

cd /
sudo mv /var/lib/waagent/Microsoft.OSTCExtensions.CustomScriptForLinux-1.2.2.0/download/0/app.js /opt/app.js

cd /opt

sudo apt-get -y install nodejs
sudo apt-get -y install npm
sudo npm -y install express
sudo npm -y install mongodb






 