#!/bin/bash

dbpass=$1
export DEBIAN_FRONTEND=noninteractive

# install the LAMP stack
apt-get -y install wget curl>> /tmp/yum-install.log 2>&1

# install Java 8
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer>> /tmp/yum-java8.log 2>&1

# install the MySQL stack
echo "deb https://jfrog.bintray.com/artifactory-pro-debs trusty main" | tee -a /etc/apt/sources.list
curl https://bintray.com/user/downloadSubjectPublicKey?username=jfrog | apt-key add -
apt-get update
apt-get -y install nginx>> /tmp/yum-nginx.log 2>&1
apt-get -y install jfrog-artifactory-pro>> /tmp/yum-artifactory.log 2>&1

# start Artifactory
service artifactory start
service nginx start