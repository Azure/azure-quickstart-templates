#!/usr/bin/env bash

source utils.sh

echo "Start to update package lists from repositories..."
retryop "apt-get update"

echo "Start to install prerequisites..." 
retryop "apt-get -y install build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 python-dev python-pip jq"

set -e

tenant_id=$1
client_id=$2
client_secret=$(echo $3 | base64 --decode)
custom_data_file="/var/lib/cloud/instance/user-data.txt"
settings=$(cat ${custom_data_file})

function get_setting() {
  key=$1
  local value=$(echo $settings | jq ".$key" -r)
  echo $value
}

function install_bosh_cli() {
  echo "Start to install bosh-cli v2..."
  bosh_cli_url=$1
  wget $bosh_cli_url
  chmod +x ./bosh-cli-*
  sudo mv ./bosh-cli-* /usr/local/bin/bosh
}

environment=$(get_setting ENVIRONMENT)

set +e

echo "Start to install python packages..."
pkg_list="setuptools==32.3.1 azure==2.0.0rc1"
if [ "$environment" = "AzureChinaCloud" ]; then
  for pkg in $pkg_list; do
    retryop "pip install $pkg --index-url https://mirror.azure.cn/pypi/simple/ --default-timeout=60"
  done
else
  for pkg in $pkg_list; do
    retryop "pip install $pkg"
  done
fi

set -e

echo "Creating the containers (bosh and stemcell) and the table (stemcells) in the default storage account"
default_storage_account=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME)
default_storage_access_key=$(get_setting DEFAULT_STORAGE_ACCESS_KEY)
endpoint_suffix=$(get_setting SERVICE_HOST_BASE)
python prepare_storage_account.py ${default_storage_account} ${default_storage_access_key} ${endpoint_suffix} ${environment}

bosh_cli_url=$(get_setting BOSH_CLI_URL)
install_bosh_cli $bosh_cli_url

username=$(get_setting ADMIN_USER_NAME)
home_dir="/home/$username"

manifests_dir="$home_dir/example_manifests"
mkdir -p $manifests_dir
cp *.yml $manifests_dir
chmod 775 $manifests_dir
chmod 644 $manifests_dir/*
dpkg -i cf-cli*

cat > "$home_dir/deploy_bosh.sh" << EOF
#!/usr/bin/env bash

set -e

export BOSH_LOG_LEVEL="debug"
export BOSH_LOG_PATH="./run.log"

bosh create-env ~/example_manifests/bosh.yml \\
  --state=state.json \\
  --vars-store=~/bosh-deployment-vars.yml \\
  -o ~/example_manifests/cpi.yml \\
  -o ~/example_manifests/custom-environment.yml \\
  -o ~/example_manifests/use-azure-dns.yml \\
  -o ~/example_manifests/jumpbox-user.yml \\
EOF

if [ "$environment" = "AzureChinaCloud" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/use-managed-disks.yml \\
  -o ~/example_manifests/use-mirror-releases-for-bosh.yml \\
  -o ~/example_manifests/custom-ntp-server.yml \\
EOF
elif [ "$environment" = "AzureStack" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/azure-stack-properties.yml \\
  -v storage_account_name=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME) \\
  -v azure_stack_domain=$(get_setting AZURE_STACK_DOMAIN) \\
  -v azure_stack_resource=$(get_setting AZURE_STACK_RESOURCE) \\
EOF
else
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/use-managed-disks.yml \\
EOF
fi

cat >> "$home_dir/deploy_bosh.sh" << EOF
  -v director_name=azure \\
  -v internal_cidr=10.0.0.0/24 \\
  -v internal_gw=10.0.0.1 \\
  -v internal_ip=10.0.0.4 \\
  -v cpi_release_url=$(get_setting BOSH_AZURE_CPI_RELEASE_URL) \\
  -v cpi_release_sha1=$(get_setting BOSH_AZURE_CPI_RELEASE_SHA1) \\
  -v stemcell_url=$(get_setting STEMCELL_URL) \\
  -v stemcell_sha1=$(get_setting STEMCELL_SHA1) \\
  -v director_vm_instance_type=$(get_setting BOSH_VM_SIZE) \\
  -v vnet_name=$(get_setting VNET_NAME) \\
  -v subnet_name=$(get_setting SUBNET_NAME_FOR_BOSH) \\
  -v environment=$(get_setting ENVIRONMENT) \\
  -v subscription_id=$(get_setting SUBSCRIPTION_ID) \\
  -v tenant_id=${tenant_id} \\
  -v client_id=${client_id} \\
  -v client_secret="${client_secret}" \\
  -v resource_group_name=$(get_setting RESOURCE_GROUP_NAME) \\
  -v default_security_group=$(get_setting NSG_NAME_FOR_BOSH)
EOF
chmod 777 $home_dir/deploy_bosh.sh

cat > "$home_dir/deploy_cloud_foundry.sh" << EOF
export BOSH_ENVIRONMENT=10.0.0.4
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="\$(bosh int ~/bosh-deployment-vars.yml --path /admin_password)"
export BOSH_CA_CERT="\$(bosh int ~/bosh-deployment-vars.yml --path /director_ssl/ca)"

bosh alias-env azure
bosh -e azure login

bosh -n update-cloud-config ~/example_manifests/cloud-config.yml \\
  -v internal_cidr=10.0.16.0/20 \\
  -v internal_gw=10.0.16.1 \\
  -v vnet_name=$(get_setting VNET_NAME) \\
  -v subnet_name=$(get_setting SUBNET_NAME_FOR_CLOUD_FOUNDRY) \\
  -v security_group=$(get_setting NSG_NAME_FOR_CLOUD_FOUNDRY) \\
  -v load_balancer_name=$(get_setting LOAD_BALANCER_NAME)

bosh upload-stemcell $(get_setting STEMCELL_URL)
EOF

cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
bosh -n -d cf deploy ~/example_manifests/cf-deployment.yml \\
  --vars-store=~/cf-deployment-vars.yml \\
  -o ~/example_manifests/azure.yml \\
EOF
if [ "$environment" = "AzureChinaCloud" ]; then
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/use-azure-storage-blobstore.yml \\
  -o ~/example_manifests/use-mirror-releases-for-cf.yml \\
  -o ~/example_manifests/scale-to-one-az.yml \\
  -v system_domain=$(get_setting CLOUD_FOUNDRY_PUBLIC_IP).xip.io \\
  -v environment=$(get_setting ENVIRONMENT) \\
  -v blobstore_storage_account_name=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME) \\
  -v blobstore_storage_access_key=$(get_setting DEFAULT_STORAGE_ACCESS_KEY) \\
  -v app_package_directory_key=cc-packages \\
  -v buildpack_directory_key=cc-buildpack \\
  -v droplet_directory_key=cc-droplet \\
  -v resource_directory_key=cc-resource
EOF
elif [ "$environment" = "AzureStack" ]; then
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/scale-to-one-az.yml \\
  -o ~/example_manifests/scale-to-availability-set-no-HA.yml \\
  -v system_domain=$(get_setting CLOUD_FOUNDRY_PUBLIC_IP).xip.io
EOF
else
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/use-azure-storage-blobstore.yml \\
  -o ~/example_manifests/scale-to-one-az.yml \\
  -v system_domain=$(get_setting CLOUD_FOUNDRY_PUBLIC_IP).xip.io \\
  -v environment=$(get_setting ENVIRONMENT) \\
  -v blobstore_storage_account_name=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME) \\
  -v blobstore_storage_access_key=$(get_setting DEFAULT_STORAGE_ACCESS_KEY) \\
  -v app_package_directory_key=cc-packages \\
  -v buildpack_directory_key=cc-buildpack \\
  -v droplet_directory_key=cc-droplet \\
  -v resource_directory_key=cc-resource
EOF
fi 
chmod 777 $home_dir/deploy_cloud_foundry.sh

cat >> "$home_dir/connect_director_vm.sh" << EOF
#!/usr/bin/env bash

bosh int ~/bosh-deployment-vars.yml --path /jumpbox_ssh/private_key > jumpbox.key
chmod 600 jumpbox.key
ssh jumpbox@10.0.0.4 -i jumpbox.key
EOF
chmod 777 $home_dir/connect_director_vm.sh

cat >> "$home_dir/login_bosh.sh" << EOF
#!/usr/bin/env bash

export BOSH_ENVIRONMENT=10.0.0.4
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="\$(bosh int ~/bosh-deployment-vars.yml --path /admin_password)"
export BOSH_CA_CERT="\$(bosh int ~/bosh-deployment-vars.yml --path /director_ssl/ca)"

bosh alias-env azure
bosh -e azure login
EOF
chmod 777 $home_dir/login_bosh.sh

cat >> "$home_dir/login_cloud_foundry.sh" << EOF
#!/usr/bin/env bash

cf_admin_password="\$(bosh int ~/cf-deployment-vars.yml --path /cf_admin_password)"

cf login -a https://api.$(get_setting CLOUD_FOUNDRY_PUBLIC_IP).xip.io -u admin -p "\${cf_admin_password}" --skip-ssl-validation
EOF
chmod 777 $home_dir/login_cloud_foundry.sh

chown -R $username $home_dir

auto_deploy_bosh=$(get_setting AUTO_DEPLOY_BOSH)
if [ "$auto_deploy_bosh" != "enabled" ]; then
  echo "Finish"
  exit 0
fi

echo "Starting to deploy BOSH director..."
su -c "./deploy_bosh.sh" - $username

auto_deploy_cf=$(get_setting AUTO_DEPLOY_CLOUD_FOUNDRY)
if [ "$auto_deploy_cf" != "enabled" ]; then
  echo "Finish"
  exit 0
fi

echo "Starting to deploy Cloud Foundry..."
nohup su - $username -c "./deploy_cloud_foundry.sh" &

echo "Finish"
exit 0
