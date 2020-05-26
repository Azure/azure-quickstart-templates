#!/bin/bash
set -o errexit
set -o xtrace

# Install jq
dpkg -s jq || sudo apt-get install -y jq

# Install Confluent platform (includes Kafka schema registry)
wget -qO - http://packages.confluent.io/deb/4.1/archive.key | sudo apt-key add -
sudo add-apt-repository "deb http://packages.confluent.io/deb/4.1 stable main"
sudo apt-get update
dpkg -s confluent-platform-oss-2.11 || sudo apt-get install -y confluent-platform-oss-2.11

echo "[Unit]
Description = Confluent Schema Registry
After = network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=ohklvmadmin
ExecStart=/usr/bin/schema-registry-start /etc/schema-registry/schema-registry.properties

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/schema-registry.service

echo "
listeners=http://0.0.0.0:8081
kafkastore.connection.url=zk0-ohkl-h:2181,zk1-ohkl-h:2181,zk2-ohkl-h:2181
kafkastore.topic=_schemas
debug=false
" > /etc/schema-registry/schema-registry.properties

systemctl start schema-registry
systemctl enable schema-registry

echo "Installation successful."
