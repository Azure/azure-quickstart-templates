#!/bin/bash

dbpass=$1
export DEBIAN_FRONTEND=noninteractive

# install the LAMP stack
apt-get update
apt-get -y install mysql-server wget curl

# install Java 8
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer

# install the MySQL stack
echo "deb https://jfrog.bintray.com/artifactory-pro-debs trusty main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update
apt-get -y install jfrog-artifactory-pro

# start Artifactory
service artifactory start