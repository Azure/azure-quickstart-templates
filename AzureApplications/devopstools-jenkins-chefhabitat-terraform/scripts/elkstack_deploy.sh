#!/bin/bash
#Date - 06102017
#Developer - Sysgain

DATE=`date +%Y%m%d%T`
LOG=/tmp/elkstack_deploy.log.$DATE
HOSTIP=`hostname -i`
#storageAccount=$1


# Configure Repos for Java, Elasticsearch, Kibana Packages
echo "---Configure Repos for Java, Elasticsearch, Kibana Packages---"	>> $LOG
#sudo add-apt-repository -y ppa:webupd8team/java >> $LOG
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add - >> $LOG
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list >> $LOG
echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list >> $LOG
echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" | sudo tee -a /etc/apt/sources.list >> $LOG
echo "---Configure Repos for Azure Cli 2.0---" >> $LOG
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list >> $LOG
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893 >> $LOG

# Enable silent installation
echo "---Enable silent installation---"	>> $LOG
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

# Repository Updates 
echo "---Repository Updates---"	>> $LOG
sudo apt-get update

#Installing Packages for ELK Stack
echo "---Installing Packages for ELK Stack---"	>> $LOG
sudo apt-get -y install openjdk-8-jre-headless elasticsearch kibana nginx logstash unzip apt-transport-https azure-cli >> $LOG

#Configuring Elasticsearch
echo "---Configuring Elasticsearch---" >> $LOG
sudo sed -i 's/# network.host: 192.168.0.1/ network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml >> $LOG
sudo systemctl restart elasticsearch >> $LOG
sudo systemctl daemon-reload >> $LOG
sudo systemctl enable elasticsearch >> $LOG 

#Configuring Kibana
echo "---Configuring Kibana---" >> $LOG
sudo sed -i 's/# server.host: "0.0.0.0"/ server.host: "localhost"/g' /opt/kibana/config/kibana.yml >> $LOG
sudo systemctl daemon-reload >> $LOG
sudo systemctl enable kibana >> $LOG
sudo systemctl start kibana >> $LOG

#Configuring Nginx
echo "---Configuring Nginx---" >> $LOG
sudo sudo -v >> $LOG
echo "$7:`openssl passwd -apr1 $8`" | sudo tee -a /etc/nginx/htpasswd.users >> $LOG
#cat /dev/null > /etc/nginx/sites-available/default >> $LOG
#wget $6/scripts/default -O /etc/nginx/sites-available/default >> $LOG

sudo rm /etc/nginx/sites-available/default
sudo wget $6/scripts/default -O /etc/nginx/sites-available/default
sudo sed -i 's/example.com/localhost:5601/g' /etc/nginx/sites-available/default
sudo nginx -t >> $LOG
sudo systemctl restart nginx >> $LOG
sudo ufw allow 'Nginx Full' >> $LOG

#Generate SSL Certificates
echo "---Generate SSL Certificates---" >> $LOG
sudo mkdir -p /etc/pki/tls/certs >> $LOG
sudo mkdir /etc/pki/tls/private >> $LOG
sudo sed -i "/\[ v3_ca \]/a subjectAltName = IP: $HOSTIP" /etc/ssl/openssl.cnf >> $LOG
cd /etc/pki/tls >> $LOG
sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt >> $LOG

#Configuring Logstash
echo "---Configuring Logstash---" >> $LOG
sudo wget $6/scripts/02-beats-input.conf -O /etc/logstash/conf.d/02-beats-input.conf >> $LOG
sudo ufw allow 5044 >> $LOG
sudo wget $6/scripts/10-syslog-filter.conf -O /etc/logstash/conf.d/10-syslog-filter.conf >> $LOG
sudo wget $6/scripts/30-elasticsearch-output.conf -O /etc/logstash/conf.d/30-elasticsearch-output.conf >> $LOG
sudo /opt/logstash/bin/logstash --configtest -f /etc/logstash/conf.d/ >> $LOG
sudo systemctl restart logstash >> $LOG
sudo systemctl enable logstash >> $LOG

#Configuring Kibana Dashboards
echo "---Configuring Kibana Dashboards---" >> $LOG
cd ~
curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.2.2.zip >> $LOG
unzip beats-dashboards-*.zip >> $LOG
cd beats-dashboards-* >> $LOG
./load.sh >> $LOG

#Load Filebeat Index Template in Elasticsearch
echo "---Load Filebeat Index Template in Elasticsearch---" >> $LOG
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json >> $LOG
curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json >> $LOG
cd /etc/pki/tls/certs/
az login --service-principal -u $1 --password $2 --tenant $3 > /dev/null
az account set --subscription $5
export AZURE_STORAGE_ACCOUNT=$4
az storage container create --name kibanaclientkey --output table >> $LOG
az storage blob upload --container-name kibanaclientkey -f logstash-forwarder.crt -n logstash-forwarder.crt > /dev/null#
