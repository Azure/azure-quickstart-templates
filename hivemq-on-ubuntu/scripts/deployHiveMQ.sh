#!/bin/bash

DOWNLOAD_URL=$1

# Install Java JDK
echo "Installing Java JDK"

apt-get update --assume-yes
apt-get install unzip --assume-yes
apt-get install openjdk-7-jdk --assume-yes

# Deploy the HiveMQ package

wget --content-disposition $DOWNLOAD_URL -P /tmp/
unzip /tmp/hivemq-*.zip -d /opt
rm /tmp/hivemq-*.zip.zip
#ln -s /opt/hivemq-* /opt/hivemq
mv /opt/hivemq-* /opt/hivemq

# Create a HiveMQ user

useradd -d /opt/hivemq hivemq
chown -R hivemq:hivemq /opt/hivemq
cd /opt/hivemq
chmod +x ./bin/run.sh

# Install the init script

cp /opt/hivemq/bin/init-script/hivemq-debian /etc/init.d/hivemq
chmod +x /etc/init.d/hivemq

# Edit the HiveMQ configuration

cd /opt/hivemq/conf


# Start HiveMQ on boot

update-rc.d hivemq defaults

# Start HiveMQ
echo "Starting HiveMQ"

/etc/init.d/hivemq start
