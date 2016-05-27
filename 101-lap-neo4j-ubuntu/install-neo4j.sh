#!/bin/bash

LAPIP=$1

wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -

echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list

apt-get -y update
#no password prompt while installing neo4j server
export DEBIAN_FRONTEND=noninteractive

#install java
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java8-installer

#install neo4j server
sudo apt-get -y install neo4j
service neo4j-service start


