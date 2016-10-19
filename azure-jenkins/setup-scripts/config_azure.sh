#!/bin/sh

#echo "Usage:
#  1 sh config_azure.sh
#  2 sh config_azure.sh <Subscription ID>
#  3 sh config_azure.sh <Subscription ID> <Storage Account name>
#  4 sh config_azure.sh <Subscription ID> <Storage Account name> <Resource Group name>
#  5 sh config_azure.sh <Subscription ID> <Storage Account name> <Resource Group name> <Source Container name> <Dest Container name>
#"

SUBSCRIPTION_ID=$1
STORAGE_ACCOUNT_NAME=$2
RESOURCE_GROUP_NAME=$3
SOURCE_CONTAINER_NAME=$4
DEST_CONTAINER_NAME=$5

#TODO: find better names for the options
echo ""
echo "  1. Clear configuration"
echo "  2. Configure Azure storage"
echo "  3. Create service principal"

option_index=0
until [ $option_index -ge 1 -a $option_index -le 3 ]
do
  read -p "  Select the desired operation by typing an index number from the list and press [Enter]: " option_index
  if [ $option_index -ne 0 -o $option_index -eq 0 2>/dev/null ]
  then
    :
  else
    option_index=0
  fi
done

if [ $option_index -eq 1 ]
then
  sh ./clear_storage_config.sh
elif [ $option_index -eq 2 ]
then
  sh ./config_azure_jenkins_storage.sh $SUBSCRIPTION_ID $STORAGE_ACCOUNT_NAME $RESOURCE_GROUP_NAME $SOURCE_CONTAINER_NAME $DEST_CONTAINER_NAME
elif [ $option_index -eq 3 ]
then
  sh ./create_service_principal.sh $SUBSCRIPTION_ID
fi
