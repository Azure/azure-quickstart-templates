#!/bin/sh

echo "In order to use Jenkins with Azure web app you first create a service principal for Jenkins to run as and also to manage your azure subscription."
echo "Background article: https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/#authenticate-with-password---azure-cli"
echo "Execute the following commands:"
echo "    azure login"
echo "    azure config mode arm"
echo "    azure account show"
echo "From above record the 'data: ID' and 'data: Tenant ID' - these will be your subscription ID and tenant ID"
echo " "
echo "Create your application in Azure AD"
echo "    azure ad app create --name 'exampleapp' --home-page 'https://www.contoso.org' --identifier-uris 'https://www.contoso.org/example' --password <Your_Password>"
echo "From above record the 'data: AppId' - this will be your client ID while the password that was set will be the AppKey"
echo " "
echo "Create service principal"
echo "    azure ad sp create <AppId from previous step>"
echo " "
echo "Assign rights to service principal"
echo "    azure role assignment create --objectId <Object ID from above step> -o Owner -c /subscriptions/{subscriptionId from above step}/"
echo " "
echo " "

my_app_name_uuid=$(python -c 'import uuid; print str(uuid.uuid4())[:8]')
MY_APP_NAME="app${my_app_name_uuid}"

MY_APP_KEY=$(python -c 'import uuid; print uuid.uuid4().hex')

my_app_id_URI="${MY_APP_NAME}_id"

# request the user to login. Azure CLI requires an interactive log in. If the user is already logged in, the asking them to login
# again is effectively a no-op, although since this script is most likely to be run the first time they logon to the VM, they should not
# already be logged in.
echo "******* PLEASE LOGIN *******"
# azure login

subscriptions_list=$(azure account list --json)
subscriptions_list_count=$(echo $subscriptions_list | jq '. | length')
if [ $subscriptions_list_count -eq 0 ]
then
    echo "You need to sign up an Azure Subscription here: https://azure.microsoft.com"
    exit 1
elif [ $subscriptions_list_count -gt 1 ]
then
    echo $subscriptions_list | jq -r 'keys[] as $i | "\($i), \(.[$i] | .name)"'
    echo "Select a subscription by typing an index number from above list and press [Enter]."
    read subscription_index
    subscription_id=`echo $subscriptions_list | jq -r '.['$subscription_index'] | .id'`
    azure account set $subscription_id
fi

MY_SUBSCRIPTION_ID=$(azure account show --json | jq -r '.[0].id')
MY_TENANT_ID=$(azure account show --json | jq -r '.[0].tenantId')

azure config mode arm

my_error_check=$(azure ad sp show --search $MY_APP_NAME --json | grep "displayName" | grep -c \"$MY_APP_NAME\" )

if [ $my_error_check -gt 0 ];
then
  echo " "
  echo "Found an app id matching the one we are trying to create; we will reuse that instead"
else
  echo " "
  echo "Creating application in active directory:"
  echo "azure ad app create --name '$MY_APP_NAME' --home-page 'http://$MY_APP_NAME' --identifier-uris 'http://$my_app_id_URI/' --password $MY_APP_KEY"
  azure ad app create --name $MY_APP_NAME --home-page http://$MY_APP_NAME --identifier-uris http://$my_app_id_URI/ --password $MY_APP_KEY
  # Give time for operation to complete
  echo "Waiting for operation to complete...."
  sleep 20
  my_error_check=$(azure ad app show --search $MY_APP_NAME --json | grep "displayName" | grep -c \"$MY_APP_NAME\" )

  if [ $my_error_check -gt 0 ];
  then
    my_app_object_id=$(azure ad app show --json --search $MY_APP_NAME | jq -r '.[0].objectId')
    MY_CLIENT_ID=$(azure ad app show --json --search $MY_APP_NAME | jq -r '.[0].appId')
    echo " "
    echo "Creating the service principal in AD"
    echo "azure ad sp create -a $MY_CLIENT_ID"
    azure ad sp create -a $MY_CLIENT_ID
    # Give time for operation to complete
    echo "Waiting for operation to complete...."
    sleep 20
    my_app_sp_object_id=$(azure ad sp show --search $MY_APP_NAME --json | jq -r '.[0].objectId')

    echo "Assign rights to service principle"
    echo "azure role assignment create --objectId $my_app_sp_object_id -o Owner -c /subscriptions/$MY_SUBSCRIPTION_ID"
    azure role assignment create --objectId $my_app_sp_object_id -o Owner -c /subscriptions/$MY_SUBSCRIPTION_ID
  else
    echo " "
    echo "We've encounter an unexpected error; please hit Ctr-C and retry from the beginning"
    read my_error
  fi
fi

MY_CLIENT_ID=$(azure ad sp show --search $MY_APP_NAME --json | jq -r '.[0].appId')

echo " "
echo "Subscription ID:" $MY_SUBSCRIPTION_ID
echo "Tenant ID:" $MY_TENANT_ID
echo "Client ID:" $MY_CLIENT_ID
echo "Client Secret:" $MY_APP_KEY
echo "OAuth 2.0 Token Endpoint:" "https://login.microsoftonline.com/${MY_TENANT_ID}/oauth2/token"
echo " "
echo "You can verify the service principal was created properly by running:"
echo "azure login -u "$MY_CLIENT_ID" --service-principal --tenant $MY_TENANT_ID"
echo " "
