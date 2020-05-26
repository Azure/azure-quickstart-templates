#!/bin/bash
echo "line 1***"
sudo apt-get update 
echo "line 2***"
sudo apt-get install default-jre -y
echo "line 3***"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "line 4***"
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
echo "line 5***"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
echo "line 6***"
sudo apt update && sudo apt install elasticsearch kibana logstash
echo "line 7***"
sudo systemctl start elasticsearch.service
echo "line 8***"
sudo systemctl start elasticsearch.service
echo "line 9***"
sudo systemctl enable elasticsearch.service
echo "line 10***"
sudo curl -XGET 'localhost:9200/'
echo "line 11***"
sudo systemctl start logstash.service
echo "line 12***"
sudo systemctl start kibana.service
echo "line 13***"
sudo systemctl enable kibana.service
echo "line 14***"
sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch_old.yml
echo "line 15***"
sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml 
echo "line 16***"
sudo systemctl restart elasticsearch.service
echo "line 17***"
sudo systemctl start elasticsearch.service
echo "line 18***"
sudo systemctl enable elasticsearch.service
echo "line 19***"
sudo cp /etc/kibana/kibana.yml /etc/kibana/kibana_old.yml
echo "line 19***"
prop='server.host: '
value='0.0.0.0'
sudo echo $prop$value >> /etc/kibana/kibana.yml 
echo "line 20***"
sudo systemctl restart kibana.service
echo "line 21***"
sudo systemctl start kibana.service
echo "line 22***"
sudo systemctl enable kibana.service
echo "line 23***"
sudo mkdir /home/azure
cd /home/azure
wget http://dist.neo4j.org/neo4j-community-3.4.1-unix.tar.gz
sudo tar -xvzf neo4j-community-3.4.1-unix.tar.gz
sudo echo "dbms.connector.https.listen_address=0.0.0.0:7473" >> /home/azure/neo4j-community-3.4.1/conf/neo4j.conf
sudo echo "dbms.connector.http.listen_address=0.0.0.0:7474" >> /home/azure/neo4j-community-3.4.1/conf/neo4j.conf
sudo echo "dbms.connector.https.listen_address=0.0.0.0:7473" >> /home/azure/neo4j-community-3.4.1/conf/neo4j.conf
sudo echo "dbms.connector.bolt.listen_address=0.0.0.0:7687" >> /home/azure/neo4j-community-3.4.1/conf/neo4j.conf
cd /home/azure/neo4j-community-3.4.1/bin
sudo ./neo4j start
sudo cd /home/azure/neo4j-community-3.4.1/
sudo cd data/dbms/
sudo rm auth
sudo /home/azure/neo4j-community-3.4.1/bin/neo4j-admin set-initial-password qwerty
sudo ./neo4j restart
