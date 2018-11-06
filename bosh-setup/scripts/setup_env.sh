#!/usr/bin/env bash

source utils.sh

set -e

echo "Installing jq"
retryop "apt-get update && apt-get install -y jq"

custom_data_file="/var/lib/cloud/instance/user-data.txt"
settings=$(cat ${custom_data_file})
function get_setting() {
  key=$1
  local value=$(echo $settings | jq ".$key" -r)
  echo $value
}

# Service Principal
environment=$(get_setting ENVIRONMENT)
service_principal_type=$(get_setting SERVICE_PRINCIPAL_TYPE)
tenant_id=$1
client_id=$2
base64_encoded_client_secret_or_certificate=$3
function client_secret_or_certificate() {
  echo ${base64_encoded_client_secret_or_certificate} | base64 --decode
}

# https://bosh.io/docs/cli-v2-install/#additional-dependencies
echo "Installing OS specified dependencies for bosh create-env command"
retryop "apt-get update && apt-get install -y build-essential zlibc zlib1g-dev ruby ruby-dev openssl libxslt-dev libxml2-dev libssl-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev sqlite3"

echo "Installing BOSH CLI"
bosh_cli_url=$(get_setting BOSH_CLI_URL)
wget $bosh_cli_url
chmod +x ./bosh-cli-*
mv ./bosh-cli-* /usr/local/bin/bosh

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest#install
echo "Installing Azure CLI"
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
retryop "apt-get install apt-transport-https"
retryop "apt-get update && apt-get install azure-cli=2.0.33-1~$AZ_REPO"

echo "Creating the containers (bosh and stemcell) and the table (stemcells) in the default storage account"
default_storage_account=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME)
default_storage_access_key=$(get_setting DEFAULT_STORAGE_ACCESS_KEY)
endpoint_suffix=$(get_setting SERVICE_HOST_BASE)
connection_string="DefaultEndpointsProtocol=https;AccountName=${default_storage_account};AccountKey=${default_storage_access_key};EndpointSuffix=${endpoint_suffix}"
if [ "$environment" = "AzureStack" ]; then
  cat /var/lib/waagent/Certificates.pem >> /etc/ssl/certs/ca-certificates.crt
  export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
  az cloud update --profile 2017-03-09-profile
fi
az storage container create --name bosh --connection-string ${connection_string}
az storage container create --name stemcell --connection-string ${connection_string}
az storage table create --name stemcells --connection-string ${connection_string}

username=$(get_setting ADMIN_USER_NAME)
home_dir="/home/$username"

manifests_dir="$home_dir/example_manifests"
mkdir -p $manifests_dir
cp *.yml $manifests_dir
pushd $manifests_dir > /dev/null
  # Enable availability zones if needed
  use_availability_zones=$(get_setting USE_AVAILABILITY_ZONES)
  if [ "$use_availability_zones" == "enabled" ]; then
    sed -i '1,5d' cloud-config.yml
    cat - cloud-config.yml > cloud-config-azs-enabled.yml << EOF
---
azs:
- name: z1
  cloud_properties:
    availability_zone: '1'
- name: z2
  cloud_properties:
    availability_zone: '2'
- name: z3
  cloud_properties:
    availability_zone: '3'
EOF
    mv cloud-config-azs-enabled.yml cloud-config.yml
  fi
  if [ "${service_principal_type}" == "Certificate" ]; then
    cat > service-principal-certificate.yml << EOF
certificate: |-
$(client_secret_or_certificate | sed 's/^/  /')
EOF
  fi
  if [ "$environment" = "AzureStack" ]; then
    if [ "$(get_setting AZURE_STACK_CA_ROOT_CERTIFICATE | base64 --decode)" = "" ]; then
      cat > azure-stack-ca-cert.yml << EOF
ca_cert: |-
$(cat /var/lib/waagent/Certificates.pem | sed 's/^/  /')
EOF
    else
      cat > azure-stack-ca-cert.yml << EOF
ca_cert: |-
$(get_setting AZURE_STACK_CA_ROOT_CERTIFICATE | base64 --decode | sed 's/^/  /')
EOF
    fi
  fi
popd  > /dev/null
chmod 775 $manifests_dir
chmod 644 $manifests_dir/*
dpkg -i cf-cli*

cat > "$home_dir/deploy_bosh.sh" << EOF
#!/usr/bin/env bash

set -e

export BOSH_LOG_LEVEL="$(get_setting LOG_LEVEL_FOR_BOSH)"
export BOSH_LOG_PATH="./run.log"

bosh create-env ~/example_manifests/bosh.yml \\
  --state=state.json \\
  --vars-store=~/bosh-deployment-vars.yml \\
  -o ~/example_manifests/cpi.yml \\
  -o ~/example_manifests/use-location.yml \\
  -o ~/example_manifests/custom-cpi-release.yml \\
  -o ~/example_manifests/custom-environment.yml \\
  -o ~/example_manifests/use-azure-dns.yml \\
  -o ~/example_manifests/jumpbox-user.yml \\
  -o ~/example_manifests/keep-failed-or-unreachable-vms.yml \\
  -o ~/example_manifests/uaa.yml \\
  -o ~/example_manifests/credhub.yml \\
  -v director_name=azure \\
  -v internal_cidr=10.0.0.0/24 \\
  -v internal_gw=10.0.0.1 \\
  -v internal_ip=10.0.0.4 \\
  -v cpi_release_url=$(get_setting BOSH_AZURE_CPI_RELEASE_URL) \\
  -v cpi_release_sha1=$(get_setting BOSH_AZURE_CPI_RELEASE_SHA1) \\
  -v director_vm_instance_type=$(get_setting BOSH_VM_SIZE) \\
  -v resource_group_name=$(get_setting RESOURCE_GROUP_NAME) \\
  -v location=$(get_setting LOCATION) \\
  -v vnet_name=$(get_setting VNET_NAME) \\
  -v subnet_name=$(get_setting SUBNET_NAME_FOR_BOSH) \\
  -v default_security_group=$(get_setting NSG_NAME_FOR_BOSH) \\
  -v environment=$(get_setting ENVIRONMENT) \\
  -v subscription_id=$(get_setting SUBSCRIPTION_ID) \\
  -v tenant_id=${tenant_id} \\
  -v client_id=${client_id} \\
EOF

if [ "${service_principal_type}" == "Password" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -v client_secret="$(client_secret_or_certificate)" \\
EOF
elif [ "${service_principal_type}" == "Certificate" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/use-service-principal-with-certificate.yml \\
  -l ~/example_manifests/service-principal-certificate.yml \\
EOF
fi

if [ "$environment" = "AzureStack" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/use-trusted-certs.yml \\
EOF
fi

if [ "$environment" = "AzureChinaCloud" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/use-managed-disks.yml \\
  -o ~/example_manifests/use-mirror-releases-for-bosh.yml \\
  -o ~/example_manifests/custom-ntp-server.yml
EOF
elif [ "$environment" = "AzureStack" ]; then
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -v storage_account_name=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME) \\
  -o ~/example_manifests/azure-stack-properties.yml \\
  -v azure_stack_domain=$(get_setting AZURE_STACK_DOMAIN) \\
  -v azure_stack_resource=$(get_setting AZURE_STACK_RESOURCE) \\
  -v azure_stack_authentication=$(get_setting AZURE_STACK_AUTHENTICATION) \\
  -l ~/example_manifests/azure-stack-ca-cert.yml
EOF
else
  cat >> "$home_dir/deploy_bosh.sh" << EOF
  -o ~/example_manifests/use-managed-disks.yml
EOF
fi

cat >> "$home_dir/deploy_bosh.sh" << EOF

cat >> "$home_dir/.profile" << EndOfFile
# BOSH CLI
export BOSH_ENVIRONMENT=10.0.0.4
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="\$(bosh int ~/bosh-deployment-vars.yml --path /admin_password)"
export BOSH_CA_CERT="\$(bosh int ~/bosh-deployment-vars.yml --path /director_ssl/ca)"
EndOfFile
source $home_dir/.profile
EOF

chmod 777 $home_dir/deploy_bosh.sh

cat > "$home_dir/login_bosh.sh" << EOF
#!/usr/bin/env bash

export BOSH_ENVIRONMENT=10.0.0.4
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="\$(bosh int ~/bosh-deployment-vars.yml --path /admin_password)"
export BOSH_CA_CERT="\$(bosh int ~/bosh-deployment-vars.yml --path /director_ssl/ca)"

bosh alias-env azure
bosh -e azure login
EOF
chmod 777 $home_dir/login_bosh.sh

cat > "$home_dir/connect_director_vm.sh" << EOF
#!/usr/bin/env bash

bosh int ~/bosh-deployment-vars.yml --path /jumpbox_ssh/private_key > jumpbox.key
chmod 600 jumpbox.key
ssh jumpbox@10.0.0.4 -i jumpbox.key
EOF
chmod 777 $home_dir/connect_director_vm.sh

system_domain=$(get_setting SYSTEM_DOMAIN)
if [ "${system_domain}" = "NotConfigured" ]; then
  system_domain="$(get_setting CLOUD_FOUNDRY_PUBLIC_IP).xip.io"
fi
cat > "$home_dir/deploy_cloud_foundry.sh" << EOF
#!/usr/bin/env bash

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
EOF

if [ "$environment" = "AzureChinaCloud" ]; then
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
bosh -n update-runtime-config ~/example_manifests/dns.yml \\
  -o ~/example_manifests/use-mirror-bosh-dns-release.yml \\
  --name=dns
EOF
else
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
bosh -n update-runtime-config ~/example_manifests/dns.yml \\
  --name=dns
EOF
fi

cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
bosh upload-stemcell --sha1=$(get_setting STEMCELL_SHA1) $(get_setting STEMCELL_URL)

bosh -n -d cf deploy ~/example_manifests/cf-deployment.yml \\
  --vars-store=~/cf-deployment-vars.yml \\
  -o ~/example_manifests/azure.yml \\
  -o ~/example_manifests/scale-to-one-az.yml \\
EOF

if [ "$environment" = "AzureChinaCloud" ]; then
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/use-mirror-compiled-releases.yml \\
EOF
else
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/use-compiled-releases.yml \\
EOF
fi

cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/use-external-blobstore.yml \\
  -v app_package_directory_key=cc-packages \\
  -v buildpack_directory_key=cc-buildpacks \\
  -v droplet_directory_key=cc-droplets \\
  -v resource_directory_key=cc-resources \\
  -o ~/example_manifests/use-azure-storage-blobstore.yml \\
  -v environment=$(get_setting ENVIRONMENT) \\
  -v blobstore_storage_account_name=$(get_setting DEFAULT_STORAGE_ACCOUNT_NAME) \\
  -v blobstore_storage_access_key=$(get_setting DEFAULT_STORAGE_ACCESS_KEY) \\
EOF
if [ "$environment" = "AzureStack" ]; then
  cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -o ~/example_manifests/use-azure-stack-storage-blobstore.yml \\
  -v blobstore_storage_dns_suffix=${endpoint_suffix} \\
EOF
fi
cat >> "$home_dir/deploy_cloud_foundry.sh" << EOF
  -v system_domain=${system_domain}
EOF
chmod 777 $home_dir/deploy_cloud_foundry.sh

cat > "$home_dir/login_cloud_foundry.sh" << EOF
#!/usr/bin/env bash

cf_admin_password="\$(bosh int ~/cf-deployment-vars.yml --path /cf_admin_password)"

cf login -a https://api.${system_domain} -u admin -p "\${cf_admin_password}" --skip-ssl-validation
EOF
chmod 777 $home_dir/login_cloud_foundry.sh

chown -R $username $home_dir

echo "The devbox is prepared successfully."

auto_deploy_bosh=$(get_setting AUTO_DEPLOY_BOSH)
if [ "$auto_deploy_bosh" != "enabled" ]; then
  echo "The BOSH director won't be deployed automatically. Finish."
  exit 0
fi

echo "Starting to deploy BOSH director..."
su - $username -c "./deploy_bosh.sh"
echo "The BOSH director is deployed successfully. Please check run.log."

auto_deploy_cf=$(get_setting AUTO_DEPLOY_CLOUD_FOUNDRY)
if [ "$auto_deploy_cf" != "enabled" ]; then
  echo "The Cloud Foundry won't be deployed automatically. Finish."
  exit 0
fi

echo "Starting to deploy Cloud Foundry, which would take some time..."
nohup su - $username -c "./deploy_cloud_foundry.sh" &

echo "Finish"
exit 0
