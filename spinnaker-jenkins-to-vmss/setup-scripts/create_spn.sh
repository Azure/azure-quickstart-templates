#!/bin/bash

# Usage : ./create_spn.sh -n "Name_of_the_Subscription" 
# -n  : (REQUIRED) the subscription name to create the spn in
# -d  : (OPTIONAL) the display name to use for the application. If not present, value will be generated. 
# -h  : (OPTIONAL) the application homepage.  If not present, value will be generated. 
# -u  : (OPTIONAL) the application auth uri.  If not present, value will be generated. 
# -p  : (OPTIONAL) the application password.  If not present, value will be generated.  
# -t  : (OPTIONAL) the tenant id.  If not present, value will be generated. 

# Check if jq installed, if not, install it.
PKG_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' jq|grep "install ok installed")
echo Checking for jq: $PKG_INSTALLED
if [ "" == "$PKG_INSTALLED" ]; then
  echo "No jq installed. installing jq..."
  sudo apt-get --force-yes --yes install jq
fi

# Default values 
app_uuid=$(python -c 'import uuid; print str(uuid.uuid4())[:8]')
DISPLAY_NAME="spinnaker"
APPLICATION_NAME="app${app_uuid}"
APPLICATION_URI="${APPLICATION_NAME}_id"
APPLICATION_KEY=$(python -c 'import uuid; print uuid.uuid4().hex')
TENANT_ID=""
SUBSCRIPTION_NAME=""

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
   -d)
   DISPLAY_NAME="$2"
   shift
   ;;
   -h)
   APPLICATION_HOME="$2"
   shift
   ;;
   -u)
   APPLICATION_URI="$2"
   shift
   ;;
   -p)
   APPLICATION_KEY="$2"
   shift
   ;;
   -t)
   TENANT_ID="$2"
   shift
   ;;
   -n)
   SUBSCRIPTION_NAME="$2"
   shift
   ;;
   *)

   ;;
esac
shift
done

echo "Debug information:"
echo " Tenant Id: "$TENANT_ID
echo " Display Name: "$DISPLAY_NAME
echo " Application Name: "$APPLICATION_NAME
echo " Application Uri: "$APPLICATION_URI
echo " Application Key: "$APPLICATION_KEY

#Validate the subscription
echo "Validating subscription info"
if [ -z "$SUBSCRIPTION_NAME" ]
then
    echo "  Subscription name parameter not present"
    exit 1  
fi

#obtain the azure account, if no account returned, invalid name.
AZURE_ACCOUNT=$(az account show --subscription "$SUBSCRIPTION_NAME")

if [ -z "$AZURE_ACCOUNT" ]
then
    echo "Invalid subscription name, no account found."
    exit 1
fi

# Obtain the tenantId of the subscriptions
if [ -z "$TENANT_ID" ]
then
    echo $AZURE_ACCOUNT
    TENANT_ID=$(echo $AZURE_ACCOUNT | jq .tenantId | sed 's/"//g')
    SUBSCRIPTION_ID=$(echo $AZURE_ACCOUNT | jq .id | sed 's/"//g')
    echo "TenantId = $TENANT_ID"
    echo "Subscription Id = $SUBSCRIPTION_ID"
fi 


### Create the application
# Check if the application already exist
my_error_check=$(az ad app list --filter "identifierUris/any(identifierUris: identifierUris eq '$APPLICATION_URI')" | jq '. | length')

if [[ $my_error_check > 0 ]] ;
then
    echo "An application already exist with this identifer-uri: $APPLICATION_URI"
    echo "We will use that application"
else
    # Create the application 
    AZAD_APP=$(az ad app create --display-name="$DISPLAY_NAME" --homepage="http://$APPLICATION_NAME" --identifier-uris="http://$APPLICATION_URI" --key-type="Password" --password="$APPLICATION_KEY")
    echo $AZAD_APP
    echo "Waiting for the creation of the app"
     # Wait for operation to complete
    sleep 10
    #  Verify if the application has been created
    ###### Add the code to verify if the app has been created 
fi

### Create the SPN 
# Obtain the ApplicationID 
APP_ID=$(az ad app list --filter "identifierUris/any(identifierUris: identifierUris eq 'http://$APPLICATION_URI')" | jq -r '.[0].appId')
echo "Application ID is: $APP_ID"
if [ -z $APP_ID ];
then 
    echo "Application not created"
else
    # The application exist, we can create the SPN
    error_check=$(az ad sp list --filter "servicePrincipalNames/any(servicePrincipalNames: servicePrincipalNames eq 'http://$APPLICATION_URI')")
    if [ "$error_check" = "[]" ];
    then 
        echo "no error, creating the SPN"
        SPN_ObjectID=$(az ad sp create --id="$APP_ID" | jq -r '.objectId')
        echo "SPNId is $SPN_ObjectID"
        echo "Waiting for the SPN creation to complete"
        # Wait for operation to complete
        sleep 10        
    fi
fi

# Do the role assignment 
az role assignment create --assignee="$SPN_ObjectID" --role="Owner" --scope="/subscriptions/$SUBSCRIPTION_ID"

echo " Subscription ID: " $SUBSCRIPTION_ID
echo " Tenant ID:" $TENANT_ID
echo " Client ID": $APP_ID
echo " Client Secret": $APPLICATION_KEY
echo "  "
echo "  You can verify the service principal was created properly by running:"
echo "  az login --username="$APP_ID" --service-principal --tenant=$TENANT_ID" --password="$APPLICATION_KEY"
echo "  "
