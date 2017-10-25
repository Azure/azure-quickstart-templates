#!/bin/bash

DOWNLOAD_URL=$1
TOTAL_INSTANCES=$2
INSTANCE_NUMBER=$3

# Install Java JDK
echo "Installing Java JDK"

apt-get update --assume-yes
apt-get install unzip --assume-yes
apt-get install openjdk-7-jdk --assume-yes

# Deploy the HiveMQ package
echo "Installing HiveMQ"

wget --content-disposition $DOWNLOAD_URL -P /tmp/
unzip /tmp/hivemq-*.zip -d /opt
rm /tmp/hivemq-*.zip
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
echo "Configuring HiveMQ"

NODE_IP=$((4+$INSTANCE_NUMBER)) # First available ip in the subnet ip range will be 4

cat > /opt/hivemq/conf/config.xml << EOF
<?xml version="1.0"?>
<hivemq xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="hivemq-config.xsd">
    <listeners>
        <tcp-listener>
            <port>1883</port>
            <bind-address>10.0.0.$NODE_IP</bind-address>
        </tcp-listener>
    </listeners>
	  <mqtt>
        <max-client-id-length>65535</max-client-id-length>
        <retry-interval>10</retry-interval>
        <max-queued-messages>1000</max-queued-messages>
    </mqtt>
    <cluster>
        <enabled>true</enabled>
        <transport>
            <tcp>
                <bind-address>10.0.0.$NODE_IP</bind-address>
                <bind-port>7800</bind-port>
            </tcp>
        </transport>
        <discovery>
            <static>
EOF

counter=0
while [ $counter -lt $TOTAL_INSTANCES ]
do
  CLUSTER_NODE_IP=$((4+$counter))
  if [ $CLUSTER_NODE_IP != $NODE_IP ]; then
cat >> /opt/hivemq/conf/config.xml << EOF
                <node>
                    <host>10.0.0.$CLUSTER_NODE_IP</host>
                    <port>7800</port>
                </node>
EOF
  fi
  counter=$(($counter+1))
done

cat >> /opt/hivemq/conf/config.xml << EOF
            </static>
        </discovery>
		    <failure-detection>
            <heartbeat>
                <enabled>true</enabled>
                <interval>5000</interval>
                <timeout>15000</timeout>
            </heartbeat>
        </failure-detection>
    </cluster>
	  <throttling>
        <max-connections>-1</max-connections>
        <max-message-size>268435456</max-message-size>
        <outgoing-limit>0</outgoing-limit>
        <incoming-limit>0</incoming-limit>
    </throttling>
    <general>
        <update-check-enabled>true</update-check-enabled>
    </general>
</hivemq>
EOF

# Start HiveMQ on boot

update-rc.d hivemq defaults

# Start HiveMQ
echo "Starting HiveMQ"

/etc/init.d/hivemq start
