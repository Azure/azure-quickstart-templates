#!/bin/bash

set -Eeuo pipefail

# Fail fast the deployment if envs are empty
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "The subscription Id is not successfully retrieved, please retry another deployment." >&2
  exit 1
fi

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "The resource group is not successfully retrieved, please retry another deployment." >&2
  exit 1
fi

if [[ -z "$ASA_SERVICE_NAME" ]]; then
  echo "The Azure Spring Apps service name is not successfully retrieved, please retry another deployment." >&2
  exit 1
fi

base_url="https://github.com/Azure-Samples/spring-petclinic-microservices/releases/download"
auth_header="no-auth"
version="3.0.1"
declare -a artifact_arr=("admin-server" "customers-service" "vets-service" "visits-service" "api-gateway")

az extension add --name spring --upgrade

for item in "${artifact_arr[@]}"
do
  jar_file_name="$item-$version.jar"
  source_url="$base_url/v$version/$jar_file_name"
  # Download binary
  echo "Downloading binary from $source_url to $jar_file_name"
  if [ "$auth_header" == "no-auth" ]; then
      curl -L "$source_url" -o $jar_file_name
  else
      curl -H "Authorization: $auth_header" "$source_url" -o $jar_file_name
  fi

  config_file_pattern="application,$item"
  az spring application-configuration-service bind --resource-group $RESOURCE_GROUP --service $ASA_SERVICE_NAME --app $item
  az spring service-registry bind --resource-group $RESOURCE_GROUP --service $ASA_SERVICE_NAME --app $item
  az spring app deploy --resource-group $RESOURCE_GROUP --service $ASA_SERVICE_NAME --name $item --artifact-path $jar_file_name --config-file-pattern $config_file_pattern
done

# Delete uami generated before exiting the script
az identity delete --ids ${AZ_SCRIPTS_USER_ASSIGNED_IDENTITY}