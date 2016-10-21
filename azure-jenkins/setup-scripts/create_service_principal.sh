#!/bin/bash

#echo "Usage:
#  1 bash create_service_principal.sh
#  2 bash create_service_principal.sh <Subscription ID>

SUBSCRIPTION_ID=$1

#echo ""
#echo "  Background article: https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal"
echo ""

my_app_name_uuid=$(python -c 'import uuid; print str(uuid.uuid4())[:8]')
MY_APP_NAME="app${my_app_name_uuid}"

MY_APP_KEY=$(python -c 'import uuid; print uuid.uuid4().hex')

my_app_id_URI="${MY_APP_NAME}_id"

#check if the user has subscriptions. If not she's probably not logged in
subscriptions_list=$(azure account list --json)
subscriptions_list_count=$(echo $subscriptions_list | jq '. | length' 2>/dev/null)
if [ $? -ne 0 ] || [ "$subscriptions_list_count" -eq "0" ]
then
  azure login
fi

if [ -z "$SUBSCRIPTION_ID" ]
then
  #prompt for subscription
  subscription_index=0
  subscriptions_list=$(azure account list --json)
  subscriptions_list_count=$(echo $subscriptions_list | jq '. | length')
  if [ $subscriptions_list_count -eq 0 ]
  then
    echo "  You need to sign up an Azure Subscription here: https://azure.microsoft.com"
    exit 1
  elif [ $subscriptions_list_count -gt 1 ]
  then
    echo $subscriptions_list | jq -r 'keys[] as $i | "  \($i+1). \(.[$i] | .name)"'

    while read -r -t 0; do read -r; done #clear stdin
    subscription_idx=0
    until [ $subscription_idx -ge 1 -a $subscription_idx -le $subscriptions_list_count ]
    do
      read -p "  Select a subscription by typing an index number from above list and press [Enter]: " subscription_idx
      if [ $subscription_idx -ne 0 -o $subscription_idx -eq 0 2>/dev/null ]
      then
        :
      else
        subscription_idx=0
      fi
    done
    subscription_index=$((subscription_idx-1))
  fi

  SUBSCRIPTION_ID=`echo $subscriptions_list | jq -r '.['$subscription_index'] | .id'`
  echo ""
fi

azure account set $SUBSCRIPTION_ID >/dev/null
if [ $? -ne 0 ]
then
  exit 1
else
  echo "  Using subscription ID $SUBSCRIPTION_ID"
  echo ""
fi

MY_SUBSCRIPTION_ID=$(azure account show --json | jq -r '.[0].id')
MY_TENANT_ID=$(azure account show --json | jq -r '.[0].tenantId')

azure config mode arm >/dev/null

my_error_check=$(azure ad sp show --search $MY_APP_NAME --json | grep "displayName" | grep -c \"$MY_APP_NAME\" )

if [ $my_error_check -gt 0 ];
then
  echo "  Found an app id matching the one we are trying to create; we will reuse that instead"
else
  echo "  Creating application in active directory:"
  echo "  azure ad app create --name '$MY_APP_NAME' --home-page 'http://$MY_APP_NAME' --identifier-uris 'http://$my_app_id_URI/' --password $MY_APP_KEY"
  azure ad app create --name $MY_APP_NAME --home-page http://$MY_APP_NAME --identifier-uris http://$my_app_id_URI/ --password $MY_APP_KEY >/dev/null
  if [ $? -ne 0 ]
  then
    exit 1
  fi
  # Give time for operation to complete
  echo "  Waiting for operation to complete...."
  sleep 20
  my_error_check=$(azure ad app show --search $MY_APP_NAME --json | grep "displayName" | grep -c \"$MY_APP_NAME\" )

  if [ $my_error_check -gt 0 ];
  then
    my_app_object_id=$(azure ad app show --json --search $MY_APP_NAME | jq -r '.[0].objectId')
    MY_CLIENT_ID=$(azure ad app show --json --search $MY_APP_NAME | jq -r '.[0].appId')
    echo " "
    echo "  Creating the service principal in AD"
    echo "  azure ad sp create -a $MY_CLIENT_ID"
    azure ad sp create -a $MY_CLIENT_ID >/dev/null
    # Give time for operation to complete
    echo "  Waiting for operation to complete...."
    sleep 20
    my_app_sp_object_id=$(azure ad sp show --search $MY_APP_NAME --json | jq -r '.[0].objectId')

    echo "  Assign rights to service principle"
    echo "  azure role assignment create --objectId $my_app_sp_object_id -o Owner -c /subscriptions/$MY_SUBSCRIPTION_ID"
    azure role assignment create --objectId $my_app_sp_object_id -o Owner -c /subscriptions/$MY_SUBSCRIPTION_ID >/dev/null
    if [ $? -ne 0 ]
    then
      exit 1
    fi
  else
    echo " "
    echo "  We've encounter an unexpected error; please hit Ctr-C and retry from the beginning"
    read my_error
  fi
fi

MY_CLIENT_ID=$(azure ad sp show --search $MY_APP_NAME --json | jq -r '.[0].appId')

echo "  "
echo "  Your access credentials ============================="
echo "  "
echo "  Subscription ID:" $MY_SUBSCRIPTION_ID
echo "  Client ID:" $MY_CLIENT_ID
echo "  Client Secret:" $MY_APP_KEY
echo "  OAuth 2.0 Token Endpoint:" "https://login.microsoftonline.com/${MY_TENANT_ID}/oauth2/token"
echo "  Tenant ID:" $MY_TENANT_ID
echo "  "
echo "  You can verify the service principal was created properly by running:"
echo "  azure login -u "$MY_CLIENT_ID" --service-principal --tenant $MY_TENANT_ID"
echo "  "
