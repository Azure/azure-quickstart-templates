#!/bin/bash

client_id=$1
client_secret=$2
subscription_id=$3
tenant_id=$4
admin_user_name=$5
resource_group=$6
master_fqdn=$7
master_count=$8
storage_account_name=$9
storage_account_key=${10}
artifacts_location=${11}
artifacts_location_sas_token=${12}

#Install Spinnaker
curl --silent https://raw.githubusercontent.com/spinnaker/spinnaker/master/InstallSpinnaker.sh | sudo bash -s -- --quiet --noinstall_cassandra

# Install Azure cli
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get -y install nodejs
sudo npm install -g azure-cli

# Login to azure cli using service principal
azure telemetry --disable
azure login --service-principal -u $client_id -p $client_secret --tenant $tenant_id
azure account set $subscription_id

# Setup temporary credentials to access kubernetes master vms
temp_user_name=$(uuidgen | sed 's/-//g')
temp_key_path=$(mktemp -d)/temp_key
ssh-keygen -t rsa -N "" -f $temp_key_path -V "+1d"
temp_pub_key=$(cat ${temp_key_path}.pub)

# Get the unique suffix used for kubernetes vms
kubernetes_suffix=$(azure group deployment list $resource_group --json | grep -A 2 'nameSuffix\|masterFQDN' | grep 'value' | \
  grep -A 1 $master_fqdn | tail -n 1 | cut -d '"' -f 4)

# Enable temporary credentials on every kubernetes master vm (since we don't know which vm will be used when we scp)
for (( i=0; i<$master_count; i++ ))
do
  master_vm="k8s-master-${kubernetes_suffix}-$i"
  azure vm extension set $resource_group $master_vm CustomScript Microsoft.Azure.Extensions 2.0 --auto-upgrade-minor-version \
    --public-config "{\"fileUris\": [\"${artifacts_location}scripts/add_temp_user.sh${artifacts_location_sas_token}\"], \"commandToExecute\": \"./add_temp_user.sh $admin_user_name $temp_user_name '$temp_pub_key'\"}"
done

# Copy kube config over from master kubernetes cluster and mark readable
sudo mkdir /home/spinnaker/.kube
sudo scp -o StrictHostKeyChecking=no -i $temp_key_path $temp_user_name@$master_fqdn:/home/$temp_user_name/.kube/config /home/spinnaker/.kube/config
sudo chmod +r /home/spinnaker/.kube/config

# Remove temporary credentials on every kubernetes master vm
for (( i=0; i<$master_count; i++ ))
do
  master_vm="k8s-master-${kubernetes_suffix}-$i"
  azure vm extension set $resource_group $master_vm CustomScript Microsoft.Azure.Extensions 2.0 --auto-upgrade-minor-version \
    --public-config "{\"fileUris\": [\"${artifacts_location}scripts/remove_temp_user.sh${artifacts_location_sas_token}\"], \"commandToExecute\": \"./remove_temp_user.sh $temp_user_name\"}"
done

# Delete temp key on spinnaker vm
rm $temp_key_path
rm ${temp_key_path}.pub

# Enable Azure storage
sudo /opt/spinnaker/install/change_cassandra.sh --echo=inMemory --front50=azs
sudo sed -i "s|storageAccountName:|storageAccountName: ${storage_account_name}|" /opt/spinnaker/config/spinnaker-local.yml
sudo sed -i "s|storageAccountKey:|storageAccountKey: ${storage_account_key}|" /opt/spinnaker/config/spinnaker-local.yml

# Install and setup Kubernetes cli for admin user
sudo curl -L -s -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
mkdir /home/${admin_user_name}/.kube
sudo cp /home/spinnaker/.kube/config /home/${admin_user_name}/.kube/config
