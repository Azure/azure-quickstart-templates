# Install Java
sudo apt-get -y update
sudo apt-get install -y $1
sudo apt-get -y update --fix-missing
sudo apt-get install -y $1

# Install tomcat
sudo apt-get install -y  $2

dpkg -L tomcat7 | grep ".*/webapps" | while read -r line ; do sudo chown $3 -R $line; done

if netstat -tulpen | grep 8080
then
	exit 0
fi
