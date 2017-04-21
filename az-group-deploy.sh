#!/bin/bash -e
while getopts "a:l:g:s:f:e:uv" opt; do
    case $opt in
        a)
            artifactsStagingDirectory=$OPTARG #the folder or sample to deploy
        ;;
        l)
            location=$OPTARG #location for the deployed resource group
        ;;
        g)
            resourceGroupName=$OPTARG
        ;;
        u)
            uploadArtifacts='true' #set this switch to upload/stage artifacs
        ;;
        s)
            storageAccountName=$OPTARG #storage account to use for staging, if not supplied one will be created and reused
        ;;
        f)
            templateFile=$OPTARG
        ;;
        e)
            parametersFile=$OPTARG
        ;;
        v)
            validateOnly='true'
        ;;
    esac
done
    
[[ $# -eq 0 || -z $artifactsStagingDirectory || -z $location ]] && { echo "Usage: $0 <-a foldername> <-l location> [-e parameters-file] [-g resource-group-name] [-u] [-s storageAccountName] [-v]"; exit 1; }

if [[ -z $templateFile ]]
then
    templateFile="$artifactsStagingDirectory/azuredeploy.json"
fi
if [[ -z $parametersFile ]]
then
    parametersFile="$artifactsStagingDirectory/azuredeploy.parameters.json"
fi

templateName="$( basename "${templateFile%.*}" )"
templateDirectory="$( dirname "$templateFile")"

if [[ -z $resourceGroupName ]]
then
    resourceGroupName=${artifactsStagingDirectory}
fi

parameterJson=$( cat "$parametersFile" | jq '.parameters' )

if [[ $uploadArtifacts ]]
then

    if [[ -z $storageAccountName ]]
    then    

        subscriptionId=$( azure account show --json | jq -r '.[0].id' )
        subscriptionId="${subscriptionId//-/}" 
        subscriptionId="${subscriptionId:0:19}"
        artifactsStorageAccountName="stage$subscriptionId"
        artifactsResourceGroupName="ARM_Deploy_Staging"    

        if [[ -z $( az storage account list -o json | jq -r '.[].name | select(. == '\"$artifactsStorageAccountName\"')' ) ]]
        then
            az group create -n "$artifactsResourceGroupName" -l "$location"
            az storage account create -l "$location" --sku "Standard_LRS" -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" 2>/dev/null
        fi
    else
        artifactsResourceGroupName=$( az storage account list -o json | jq -r '.[] | select(.name == '\"$s\"') .resourceGroup' )
        if [[ -z $artifactsResourceGroupName ]] 
        then
            echo "Cannot find storageAccount: "$storageAccountName
        fi   
    fi
    
    artifactsStorageContainerName=${resourceGroupName}"-stageartifacts"
    artifactsStorageContainerName=$( echo "$artifactsStorageContainerName" | awk '{print tolower($0)}')
    
    artifactsStorageAccountKey=$( az storage account keys list -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" -o json | jq -r '.[0].value' )
    az storage container create -n "$artifactsStorageContainerName" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" >/dev/null 2>&1
    
    # Get a 4-hour SAS Token for the artifacts container. Fall back to OSX date syntax if Linux syntax fails.
    plusFourHoursUtc=$(date -u -v+4H +%Y-%m-%dT%H:%MZ 2>/dev/null)  || plusFourHoursUtc=$(date -u --date "$dte 4 hour" +%Y-%m-%dT%H:%MZ)

    sasToken=$( az storage container generate-sas -n "$artifactsStorageContainerName" --permissions r --expiry "$plusFourHoursUtc" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" -o json | sed 's/"//g')

    blobEndpoint=$( az storage account show -n "$artifactsStorageAccountName" -g "$artifactsResourceGroupName" -o json | jq -r '.primaryEndpoints.blob' )

    parameterJson=$( echo "$parameterJson"  | jq "{_artifactsLocation: {value: "\"$blobEndpoint$artifactsStorageContainerName"\"}, _artifactsLocationSasToken: {value: \"?"$sasToken"\"}} + ." )

    artifactsStagingDirectory=$( echo "$artifactsStagingDirectory" | sed 's/\/*$//')
    artifactsStagingDirectoryLen=$((${#artifactsStagingDirectory} + 1))

    for filepath in $( find "$artifactsStagingDirectory" -type f )
    do
        relFilePath=${filepath:$artifactsStagingDirectoryLen}
        echo "Uploading file $relFilePath..."
        az storage blob upload -f $filepath --container $artifactsStorageContainerName -n $relFilePath --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" --verbose
    done 
fi

az group create -n "$resourceGroupName" -l "$location"

# Remove line endings from parameter JSON so it can be passed in to the CLI as a single line
parameterJson=$( echo "$parameterJson" | jq -c '.' )

if [[ $validateOnly ]]
then
    az group deployment validate -g "$resourceGroupName" --template-file $templateFile --parameters "$parameterJson" --verbose
else
    az group deployment create -g "$resourceGroupName" -n AzureRMSamples --template-file $templateFile --parameters "$parameterJson" --verbose
fi