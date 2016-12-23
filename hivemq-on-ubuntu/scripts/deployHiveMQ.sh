#!/bin/bash

DOWNLOADURL=$1

# Install Java JDK
echo "Installing Java JDK"

apt-get install unzip --assume-yes
apt-get install openjdk-7-jdk --assume-yes

wget --content-disposition $DOWNLOADURL -P /tmp/
unzip /tmp/hivemq-*.zip -d /opt
rm /tmp/hivemq-*.zip.zip

mv /opt/hivemq-* /opt/hivemq
