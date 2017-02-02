#!/bin/bash

admin_user_name=$1
temp_user_name=$2
temp_public_key=$3

# Add user
sudo useradd $temp_user_name --create-home

# Add public key
sudo mkdir /home/$temp_user_name/.ssh
echo $temp_public_key | sudo tee -a /home/$temp_user_name/.ssh/authorized_keys

# Copy kube config file and give user permission to access
sudo mkdir /home/$temp_user_name/.kube
sudo cp /home/$admin_user_name/.kube/config /home/$temp_user_name/.kube/config
sudo chown $temp_user_name /home/$temp_user_name/.kube/config