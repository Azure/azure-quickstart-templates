#!/bin/bash

storage_account_name=$1
storage_account_key=$2

curl --silent https://raw.githubusercontent.com/spinnaker/spinnaker/master/InstallSpinnaker.sh | sudo bash -s -- --quiet --noinstall_cassandra

# Enable Azure storage
sudo /opt/spinnaker/install/change_cassandra.sh --echo=inMemory --front50=azs
sudo sed -i "s|storageAccountName:|storageAccountName: ${storage_account_name}|" /opt/spinnaker/config/spinnaker-local.yml
sudo sed -i "s|storageAccountKey:|storageAccountKey: ${storage_account_key}|" /opt/spinnaker/config/spinnaker-local.yml

# Restart spinnaker so that config changes take effect
sudo service spinnaker restart