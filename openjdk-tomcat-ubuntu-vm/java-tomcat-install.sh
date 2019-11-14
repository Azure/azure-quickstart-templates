# Install Java
# Install Java
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get install -y openjdk-13-jdk
sudo apt-get -y update --fix-missing
sudo apt-get install -y openjdk-13-jdk

# Install tomcat
sudo apt-get install -y  tomcat9

# Update and then close
sudo apt-get -y update
sudo apt-get -y upgrade

if netstat -tulpen | grep 8080
then
exit 0
fi
