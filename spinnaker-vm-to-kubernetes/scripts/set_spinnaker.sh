#!/bin/bash

while getopts :i:p:s:t:u:g:f:c:n:k:r:e:a:o:l:y:x: option; do
  case "${option}" in
        i) client_id="${OPTARG}";;
        p) client_secret="${OPTARG}";;
        s) subscription_id="${OPTARG}";;
        t) tenant_id="${OPTARG}";;
        u) admin_user_name="${OPTARG}";;
        g) resource_group="${OPTARG}";;
        f) master_fqdn="${OPTARG}";;
        c) master_count="${OPTARG}";;
        n) storage_account_name="${OPTARG}";;
        k) storage_account_key="${OPTARG}";;
        r) azure_container_registry="${OPTARG}";;
        e) include_kubernetes_pipeline="${OPTARG}";;
        l) pipeline_registry="${OPTARG}";;
        y) pipeline_repository="${OPTARG}";;
        x) pipeline_port="${OPTARG}";;
        a) artifacts_location="${OPTARG}";;
        o) artifacts_location_sas_token="${OPTARG}";;
    esac
done

spinnaker_config_dir="/opt/spinnaker/config/"
clouddriver_config_file="${spinnaker_config_dir}clouddriver-local.yml"
igor_config_file="${spinnaker_config_dir}igor-local.yml"
spinnaker_config_file="${spinnaker_config_dir}spinnaker-local.yml"
spinnaker_kube_config_file="/home/spinnaker/.kube/config"
kubectl_file="/usr/local/bin/kubectl"
docker_hub_registry="index.docker.io"

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
sudo scp -o StrictHostKeyChecking=no -i $temp_key_path $temp_user_name@$master_fqdn:/home/$temp_user_name/.kube/config $spinnaker_kube_config_file
sudo chmod +r $spinnaker_kube_config_file

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
sudo sed -i "s|storageAccountName:|storageAccountName: ${storage_account_name}|" $spinnaker_config_file
sudo sed -i "s|storageAccountKey:|storageAccountKey: ${storage_account_key}|" $spinnaker_config_file

# Install and setup Kubernetes cli for admin user
sudo curl -L -s -o $kubectl_file https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x $kubectl_file
mkdir /home/${admin_user_name}/.kube
sudo cp $spinnaker_kube_config_file /home/${admin_user_name}/.kube/config

# Configure Spinnaker for Docker Hub and Azure Container Registry
sudo wget -O $clouddriver_config_file "${artifacts_location}resources/clouddriver-local.yml${artifacts_location_sas_token}"

sudo sed -i "s|REPLACE_ACR_REGISTRY|${azure_container_registry}|" $clouddriver_config_file
sudo sed -i "s|REPLACE_ACR_USERNAME|${client_id}|" $clouddriver_config_file
sudo sed -i "s|REPLACE_ACR_PASSWORD|${client_secret}|" $clouddriver_config_file

# Replace pipeline repository in config if specified
if [ "$pipeline_registry" == "$docker_hub_registry" ] && [ -n "$pipeline_repository" ]; then
    sudo sed -i "s|REPLACE_PIPELINE_REPOSITORY|${pipeline_repository}|" $clouddriver_config_file
else
    sudo sed -i "/REPLACE_PIPELINE_REPOSITORY/d" $clouddriver_config_file
fi

# Enable docker registry in Igor so that triggers work
sudo touch "$igor_config_file"
sudo cat <<EOF >"$igor_config_file"
dockerRegistry:
  enabled: true
EOF

# Restart spinnaker so that config changes take effect
curl --silent "${artifacts_location}scripts/await_restart_spinnaker.sh${artifacts_location_sas_token}" | sudo bash -s

# Create pipeline if enabled
if (( $include_kubernetes_pipeline )); then
    if [ "$pipeline_registry" == "$docker_hub_registry" ]; then
        docker_account_name="docker-hub-registry"
        pipeline_registry_url="$docker_hub_registry"
    else
        docker_account_name="azure-container-registry"
        pipeline_registry_url="$azure_container_registry"
    fi

    curl --silent "${artifacts_location}scripts/add_pipeline.sh${artifacts_location_sas_token}" | sudo bash -s -- "$docker_account_name" "$pipeline_registry_url" "$pipeline_repository" "$pipeline_port" "[anonymous]" "anonymous@Fabrikam.com" "$artifacts_location" "$artifacts_location_sas_token"
fi