# Install Java
sudo /bin/date +%H:%M:%S > /home/$1/install.progress.txt
echo "Installing openjdk-8-jdk package" >> /home/$1/install.progress.txt

sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get -y update

sudo apt-get install -y openjdk-8-jdk
sudo apt-get -y update --fix-missing

sudo apt-get install -y openjdk-8-jdk
sudo ln -s /usr/lib/jvm/java-8-openjdk-amd64/ /usr/lib/jvm/default-java

sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt
  
# Install Apache NiFi
echo "Installing NiFi 1.1.2" >> /home/$1/install.progress.txt
sudo mkdir /usr/bin/nifi
cd /usr/bin/nifi
sudo wget ftp://apache.mirrors.tds.net/pub/apache.org/nifi/1.1.2/nifi-1.1.2-bin.tar.gz
sudo tar -xzf nifi-1.1.2-bin.tar.gz
sudo /usr/bin/nifi/nifi-1.1.2/bin/nifi.sh install dataflow
sudo /usr/bin/nifi/nifi-1.1.2/bin/nifi.sh start 
# Increase the number of TCP socket ports available
sudo sysctl -w net.ipv4.ip_local_port_range="10000 65000"

 
sudo /bin/date +%H:%M:%S >> /home/$1/install.progress.txt

echo "nifi installation done" >> /home/$1/install.progress.txt
