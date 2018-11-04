#!/bin/bash -e
# Set defaultValues for optional args
artifactsStagingDirectory='.'
createUIDefFile='createUIDefinition.json'

while getopts "a:l:s:f:g" opt; do
    case $opt in
        a)
            artifactsStagingDirectory=$OPTARG #the folder for the createUIDefinition.json file
        ;;
        l)
            storageLocation=$OPTARG #location for the staging storage account if it needs to be created
        ;;
        f)
            createUIDefFile=$OPTARG
        ;;
        g)
            gov='false'
        ;;
    esac
done

#you must be logged into azure before running this script - run "az login"
subscriptionId=$( az account show -o json | jq -r '.id' )
subscriptionId="${subscriptionId//-/}" 
subscriptionId="${subscriptionId:0:19}"
artifactsStorageAccountName="stage$subscriptionId"
artifactsResourceGroupName="ARM_Deploy_Staging"    

echo "Checking for storage account..."
if [[ -z $( az storage account list -o json | jq -r '.[].name | select(. == '\"$artifactsStorageAccountName\"')' ) ]]
then
    if [[ -z $storageLocation ]] 
    then
        echo "-l (storageLocation) must be specified when storageAccount needs to be created, usually on first run for a subscription."
        exit 1
    fi
    echo "Creating storage account..."
    az group create -n "$artifactsResourceGroupName" -l "$storageLocation"
    az storage account create -l "$storageLocation" --sku "Standard_LRS" -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" 2>/dev/null
fi

artifactsStorageContainerName="createuidef-stageartifacts"

artifactsStorageAccountKey=$( az storage account keys list -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" -o json | jq -r '.[0].value' )

az storage container create -n "$artifactsStorageContainerName" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" >/dev/null 2>&1

uiDefFilePath="$artifactsStagingDirectory/$createUIDefFile"

az storage blob upload -f "$uiDefFilePath" --container $artifactsStorageContainerName -n $createUIDefFile --account-name $artifactsStorageAccountName  >/dev/null

# Get a 4-hour SAS Token for the artifacts container. Fall back to OSX date syntax if Linux syntax fails.
plusFourHoursUtc=$(date -u -v+4H +%Y-%m-%dT%H:%MZ 2>/dev/null)  || plusFourHoursUtc=$(date -u --date "$dte 4 hour" +%Y-%m-%dT%H:%MZ)
sasToken=$( az storage container generate-sas -n "$artifactsStorageContainerName" --permissions r --expiry "$plusFourHoursUtc" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" -o json | sed 's/"//g')

blobEndpoint=$( az storage account show -n "$artifactsStorageAccountName" -g "$artifactsResourceGroupName" -o json | jq -r '.primaryEndpoints.blob' )
createUIDefUrl=$blobEndpoint$artifactsStorageContainerName/$createUIDefFile?$sasToken

createUIDefUrlEncoded=$(printf %s "$createUIDefUrl" | jq -s -R -r @uri)

if [[ $gov ]] 
then
target="https://portal.azure.us/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"\""initialData"\"":{},"\""providerConfig"\"":{"\""createUiDefinition"\"":"\""$createUIDefUrlEncoded"\""}}"
else
target="https://portal.azure.com/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"\""initialData"\"":{},"\""providerConfig"\"":{"\""createUiDefinition"\"":"\""$createUIDefUrlEncoded"\""}}"
fi

echo "Launch browser with this URL:"
echo
echo $target
echo 

#note chrome will not launch with the encoded url no idea why - copy/paste works (or safari)
python -mwebbrowser $target
