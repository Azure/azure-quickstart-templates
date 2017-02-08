#!/bin/bash

#echo "Usage:
#  1 bash config_azure.sh
#  2 bash config_azure.sh <Subscription ID>
#  3 bash config_azure.sh <Subscription ID> <Storage Account name>
#  4 bash config_azure.sh <Subscription ID> <Storage Account name> <Resource Group name>
#  5 bash config_azure.sh <Subscription ID> <Storage Account name> <Resource Group name> <Source Container name> <Dest Container name>
#"
SUBSCRIPTION_ID=$1
STORAGE_ACCOUNT_NAME=$2
RESOURCE_GROUP_NAME=$3
SOURCE_CONTAINER_NAME=$4
DEST_CONTAINER_NAME=$5

#TODO: find better names for the options
echo ""
echo "  1. All of the below"
echo "  2. Clear Azure storage configuration"
echo "  3. Configure Azure storage"
echo "  4. Get Azure Credentials"

while read -r -t 0; do read -r; done #clear stdin
option_index=0
until [ $option_index -ge 1 -a $option_index -le 4 ]
do
  read -p "  Select the desired operation by typing an index number from the list and press [Enter]: " option_index
  if [ $option_index -ne 0 -o $option_index -eq 0 2>/dev/null ]
  then
    :
  else
    option_index=0
  fi
done

instruction_use_service_principal="Enter the above values into your Azure Profile Configuration in Jenkins"

scripts_dir=$(dirname $0)

if [ $option_index -eq 1 ]
then
  bash ${scripts_dir}/clear_storage_config.sh
  bash ${scripts_dir}/config_azure_jenkins_storage.sh $SUBSCRIPTION_ID $STORAGE_ACCOUNT_NAME $RESOURCE_GROUP_NAME $SOURCE_CONTAINER_NAME $DEST_CONTAINER_NAME
  bash ${scripts_dir}/create_service_principal.sh $SUBSCRIPTION_ID
  echo "  $instruction_use_service_principal"
elif [ $option_index -eq 2 ]
then
  bash ${scripts_dir}/clear_storage_config.sh
elif [ $option_index -eq 3 ]
then
  bash ${scripts_dir}/config_azure_jenkins_storage.sh $SUBSCRIPTION_ID $STORAGE_ACCOUNT_NAME $RESOURCE_GROUP_NAME $SOURCE_CONTAINER_NAME $DEST_CONTAINER_NAME
elif [ $option_index -eq 4 ]
then
  bash ${scripts_dir}/create_service_principal.sh $SUBSCRIPTION_ID
  echo "  $instruction_use_service_principal"
fi