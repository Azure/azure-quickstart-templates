#!/bin/bash

showErrorAndUsage() {
  echo
  if [[ "$1" != "" ]]
  then
    echo "  error:  $1"
    echo
  fi

  echo "usage:  $(basename ${0}) [options]"
  echo "options:"
  echo "  -l <location>                     : [Required] Location to deploy to. Ex. westus, eastus, ukwest, japaneast, etc."
  echo "  -f <template file name>           : ARM template file containing the resources to deploy. Uses 'azuredeploy.json' if not provided."
  echo "  -p <template parameter file name> : ARM template parameter file. Uses 'azuredeploy.parameters.json' if not provided."
  echo "  -r <resource group name>          : Resource group name to deploy resources into.  Uses 'Azure-QuickStart-Resource-Group' if not provided."
  echo "  -s <staging storage account name> : Storage account to upload artifacts to. If not provided, a unique one will be created and reused."
  echo "  -u                                : Upload artifacts such as nested deployment template files and custom scripts."
  echo "  -v                                : Validate the template(s) but don't deploy the resources."
  exit 1
}

VALIDATE_ONLY=false
UPLOAD_ARTIFACTS=false
LOCATION=""
STAGING_STORAGE_ACCOUNT_NAME=""
PARAMETERS=""

# Resource group name that will contain the storage account to hold artifacts during deployment.
STAGING_RESOURCE_GROUP_NAME="ARM_Deploy_Staging"  

# Resource group name to deploy resources into.
RESOURCE_GROUP_NAME="Azure-QuickStart-Resource-Group"

# Template file and parameters files describing the resources to deploy.
TEMPLATE_FILE="azuredeploy.json"
TEMPLATE_PARAMETERS_FILE="azuredeploy.parameters.json"

while getopts "l:f:p:r:s:uv" opt; do
    case $opt in
        l)
            LOCATION=$OPTARG
            ;;
        f)
            TEMPLATE_FILE=$OPTARG
            ;;            
        p)
            TEMPLATE_PARAMETERS_FILE=$OPTARG
            ;;
        r)
            RESOURCE_GROUP_NAME=$OPTARG
            ;;
        s)
            STAGING_STORAGE_ACCOUNT_NAME=$OPTARG
            ;;
        u)
            UPLOAD_ARTIFACTS=true
            ;;
        v)
            VALIDATE_ONLY=true
            ;;
        ?)
            showErrorAndUsage
            ;;
    esac
done

if [[ $LOCATION == "" ]]
then
    showErrorAndUsage
fi

ARTIFACT_STAGING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_FILE="${ARTIFACT_STAGING_DIR}/${TEMPLATE_FILE}"
TEMPLATE_PARAMETERS_FILE="${ARTIFACT_STAGING_DIR}/${TEMPLATE_PARAMETERS_FILE}"

# Get the Azure Subscription Id 
SUBSCRIPTION_ID=$( az account show --query id )
SUBSCRIPTION_ID=${SUBSCRIPTION_ID//[\"]/}
echo "Using Azure subscription Id '$SUBSCRIPTION_ID'."
echo ""

if [[ $UPLOAD_ARTIFACTS == true ]]
then
    # Create the resource group for the storage account if it does not already exist.
    RESOURCE_GROUP_EXISTS=$( az group exists --name ${STAGING_RESOURCE_GROUP_NAME} )
    if [[ $RESOURCE_GROUP_EXISTS == "false" ]]
    then
        echo "Creating resource group '$STAGING_RESOURCE_GROUP_NAME'."
        az group create --location $LOCATION --name $STAGING_RESOURCE_GROUP_NAME
    fi

    # Create a storage account name to upload the artifacts to.
    if [[ $STAGING_STORAGE_ACCOUNT_NAME == "" ]]
    then
        STAGING_STORAGE_ACCOUNT_NAME=${SUBSCRIPTION_ID//[-]/}
        STAGING_STORAGE_ACCOUNT_NAME=$( expr substr $STAGING_STORAGE_ACCOUNT_NAME 1 19 )
        STAGING_STORAGE_ACCOUNT_NAME="stage${STAGING_STORAGE_ACCOUNT_NAME}"
    fi

    # Create a container name to hold the artifacts.
    STAGING_CONTAINER_NAME="${RESOURCE_GROUP_NAME,,}-stageartifacts"

    # Create the storage account if it doesn't already exist.
    STAGING_STORAGE_ACCOUNT_NAME_AVAIL=$( az storage account check-name --name $STAGING_STORAGE_ACCOUNT_NAME --output tsv | cut -f2) 
    STAGING_STORAGE_ACCOUNT_NAME_AVAIL=${STAGING_STORAGE_ACCOUNT_NAME_AVAIL,,}
    if [[ $STAGING_STORAGE_ACCOUNT_NAME_AVAIL == "true" ]]
    then
        echo "Storage account '$STAGING_STORAGE_ACCOUNT_NAME' does not exist.  Creating in resource group '$STAGING_RESOURCE_GROUP_NAME'."
        az storage account create --location $LOCATION --name $STAGING_STORAGE_ACCOUNT_NAME \
            --resource-group $STAGING_RESOURCE_GROUP_NAME --sku Standard_LRS
        echo "Creating container '$STAGING_CONTAINER_NAME' in storage account '$STAGING_STORAGE_ACCOUNT_NAME'."
        az storage container create --name $STAGING_CONTAINER_NAME --account-name $STAGING_STORAGE_ACCOUNT_NAME
    else
        STG_CONTAINER_EXISTS=$( az storage container exists --name $STAGING_CONTAINER_NAME \
                --account-name $STAGING_STORAGE_ACCOUNT_NAME --output tsv )
        if [[ ${STG_CONTAINER_EXISTS,,} == "false" ]]
        then
            echo "Creating container '$STAGING_CONTAINER_NAME' in storage account '$STAGING_STORAGE_ACCOUNT_NAME'."
            az storage container create --name $STAGING_CONTAINER_NAME --account-name $STAGING_STORAGE_ACCOUNT_NAME  
        fi
    fi

    # Get the key for the storage account we will upload artifacts to.
    STAGING_STORAGE_ACCOUNT_KEYS=$( az storage account keys list --account-name $STAGING_STORAGE_ACCOUNT_NAME \
            --resource-group $STAGING_RESOURCE_GROUP_NAME --output tsv | cut -f3 )
    IFS=' ' read -a STAGING_STORAGE_ACCOUNT_KEYS <<< "${STAGING_STORAGE_ACCOUNT_KEYS}"
    STAGING_STORAGE_ACCOUNT_KEY=${STAGING_STORAGE_ACCOUNT_KEYS[1]}  

    # Upload files/artifacts to storage account.
    find -P $ARTIFACT_STAGING_DIR -type f |
    while read artifact_file
    do
        blob_name=${artifact_file: (${#ARTIFACT_STAGING_DIR} + 1)}
        echo "Uploading $blob_name ..."
        az storage blob upload -f $artifact_file -c $STAGING_CONTAINER_NAME -n $blob_name \
            --account-name $STAGING_STORAGE_ACCOUNT_NAME --account-key "${STAGING_STORAGE_ACCOUNT_KEY}"
    done
    echo ""

    # Generate a SAS token for the storage container the artifacts were uploaded to
    ARTIFACTS_LOCATION="https://${STAGING_STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${STAGING_CONTAINER_NAME}"
    SAS_EXPIRY=$( date -u -d "+8 hours" +%Y-%m-%dT%TZ )
    ARTIFACTS_LOCATION_SAS_TOKEN=$( az storage container generate-sas --name $STAGING_CONTAINER_NAME --permissions r --account-name $STAGING_STORAGE_ACCOUNT_NAME --expiry $SAS_EXPIRY )
    ARTIFACTS_LOCATION_SAS_TOKEN=${ARTIFACTS_LOCATION_SAS_TOKEN//[\"]/}
    ARTIFACTS_LOCATION_SAS_TOKEN="?$ARTIFACTS_LOCATION_SAS_TOKEN"

    # Build JSON string for parameters to pass to resource group deployment.
    PARAMETERS="{\"_artifactsLocation\": {\"value\": \"${ARTIFACTS_LOCATION}\" }, \"_artifactsLocationSasToken\": {\"value\": \"${ARTIFACTS_LOCATION_SAS_TOKEN}\" } }"
fi

# Create the resource group for the deployment.
RESOURCE_GROUP_EXISTS=$( az group exists --name ${RESOURCE_GROUP_NAME} )
if [[ $RESOURCE_GROUP_EXISTS == "false" ]]
then
    echo "Creating resource group '$RESOURCE_GROUP_NAME' in '$LOCATION'."
    PROVISIONING_STATE=$( az group create --location $LOCATION --name $RESOURCE_GROUP_NAME --query "properties.provisioningState" )
    PROVISIONING_STATE=${PROVISIONING_STATE//[\"]/}
    echo "$PROVISIONING_STATE"
fi

if [[ $VALIDATE_ONLY == true ]]
then
    # Validate the ARM templates only - don't deploy.
    echo "Validating resource group deployment..."
    echo "$TEMPLATE_PARAMETERS_FILE"
    az group deployment validate --resource-group $RESOURCE_GROUP_NAME \
        --template-file $TEMPLATE_FILE \
        --parameters @${TEMPLATE_PARAMETERS_FILE} --parameters "${PARAMETERS}" --query "properties.provisioningState"
else
    # Start the resource group deployment.
    echo "Deploying to resource group... "
    DEPLOYMENT_TIME=$( date -u +%m%d-%H%M )
    DEPLOYMENT_NAME=$(basename "$TEMPLATE_FILE" .json)
    DEPLOYMENT_NAME="$DEPLOYMENT_NAME-$DEPLOYMENT_TIME"
    az group deployment create --resource-group $RESOURCE_GROUP_NAME --name $DEPLOYMENT_NAME \
        --template-file $TEMPLATE_FILE \
        --parameters @${TEMPLATE_PARAMETERS_FILE} --parameters "${PARAMETERS}" --no-wait

    # Color codes used when showing polling output.
    LIGHT_CYAN='\033[1;36m'
    NO_COLOR='\033[0m'

    # Poll the deployment status every 10 seconds.
    INTERVAL=10
    PROVISIONING_STATE="Checking provisioning state every $INTERVAL seconds"
    while [ "$PROVISIONING_STATE" != "Succeeded" ] && [ "$PROVISIONING_STATE" != "Failed" ]
    do
        DEPLOYMENT_CHECK_TIME=$( date +%H:%m:%S' '%p)
        echo -e "${LIGHT_CYAN}    $DEPLOYMENT_CHECK_TIME - $PROVISIONING_STATE ... ${NO_COLOR}"
        sleep $INTERVAL
        PROVISIONING_STATE=$( az group deployment show --name $DEPLOYMENT_NAME --resource-group $RESOURCE_GROUP_NAME --query "properties.provisioningState" )
        PROVISIONING_STATE=${PROVISIONING_STATE//[\"]/}
    done

    echo ""
    echo "    $PROVISIONING_STATE"
    echo ""
fi
