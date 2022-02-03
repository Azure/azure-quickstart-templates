#!/bin/bash

wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -

echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list

apt-get -y update
#no password prompt while installing neo4j server
export DEBIAN_FRONTEND=noninteractive

#install java
apt-get install -y python-software-properties debconf-utils
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer

#install neo4j server
apt-get -y install neo4j
#make a copy of the config file
cp -p /etc/neo4j/neo4j.conf /etc/neo4j/neo4j.conf.bak
#open the http access at port 7474 to apache node
sed -i -e '/dbms.connector.http.address/s/^#//' /etc/neo4j/neo4j.conf
service neo4j restart


