#!/bin/bash -e
while getopts "a:l:g:s:f:e:uvdb" opt; do
    case $opt in
        a)
            artifactsStagingDirectory=$OPTARG #the folder or sample to deploy
        ;;
        l)
            location=$OPTARG #location for the deployed resource group
        ;;
        g)
            resourceGroupName=$OPTARG #name of the resource group to create
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
            validateOnly='true' #validate the template without deploying
        ;;
        d)
            devMode='true' #dev mode automatically selects a different parameter file without explicitly specifying it
        ;;        
        b)
            bicep='true' #dev mode automatically selects a different parameter file without explicitly specifying it
        ;;
    esac
done

[[ $# -eq 0 || -z $artifactsStagingDirectory || -z $location ]] && { echo "Usage: $0 <-a foldername> <-l location> [-e parameters-file] [-g resource-group-name] [-u] [-s storageAccountName] [-t templateFile] [-v] [-d]"; exit 1; }

export AZURE_HTTP_USER_AGENT="AzureQuickStarts $AZURE_HTTP_USER_AGENT"

# if the switch is set or the file is a bicep file
if [[ $bicep || ($templateFile == *.bicep) ]]
then
    isBicep=true
    defaultTemplateFile="/main.bicep"
else
    isBicep=false
    defaultTemplateFile="/azuredeploy.json"
fi

if [[ -z $templateFile ]]
then
    templateFile="$artifactsStagingDirectory$defaultTemplateFile"
fi

if [[ $isBicep = true ]]
then
    bicep build $templateFile
    # after building the script will work with the json file
    t="${templateFile/.bicep/.json}"
    templateFile=$t
fi

if [[ $devMode ]]
then
    parametersFile="$artifactsStagingDirectory/azuredeploy.parameters.dev.json"
    if [ ! -f $parametersFile ]
    then
        parametersFile="$artifactsStagingDirectory/azuredeploy.parameters.1.json"
    fi
else
    if [[ -z $parametersFile ]]
    then
        parametersFile="$artifactsStagingDirectory/azuredeploy.parameters.json"
    fi
fi

echo "Using parameters file: "$parametersFile

templateName="$( basename "${templateFile%.*}" )"
templateDirectory="$( dirname "$templateFile")"

if [[ -z $resourceGroupName ]]
then
    resourceGroupName=$(basename $(cd "${artifactsStagingDirectory}" && pwd))
fi

parameterJson=$( cat "$parametersFile" | jq '.parameters' )
_artifactsLocationParameter=$( cat "$templateFile" | jq '.parameters._artifactsLocation' )
_artifactsLocationSasTokenParameter=$( cat "$templateFile" | jq '.parameters._artifactsLocationSasToken' )

if [[ $uploadArtifacts || $_artifactsLocationParameter != null || $_artifactsLocationSasTokenParameter != null ]]
then

    if [[ -z $storageAccountName ]]
    then

        subscriptionId=$( az account show -o json | jq -r '.id' )
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
        artifactsStorageAccountName=$storageAccountName
        artifactsResourceGroupName=$( az storage account list -o json | jq -r '.[] | select(.name == '\"$storageAccountName\"') .resourceGroup' )
        if [[ -z $artifactsResourceGroupName ]]
        then
            echo "Cannot find storageAccount: "$storageAccountName
        fi
    fi

    artifactsStorageContainerName=${resourceGroupName}"-stageartifacts"
    artifactsStorageContainerName=$( echo "${artifactsStorageContainerName:0:63}" | awk '{print tolower($0)}')

    artifactsStorageAccountKey=$( az storage account keys list -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" -o json | jq -r '.[0].value' )
    az storage container create -n "$artifactsStorageContainerName" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" >/dev/null 2>&1

    # Get a 4-hour SAS Token for the artifacts container. Fall back to OSX date syntax if Linux syntax fails.
    plusFourHoursUtc=$(date -u -v+4H +%Y-%m-%dT%H:%MZ 2>/dev/null)  || plusFourHoursUtc=$(date -u --date "$dte 4 hour" +%Y-%m-%dT%H:%MZ)

    sasToken=$( az storage container generate-sas -n "$artifactsStorageContainerName" --permissions r --expiry "$plusFourHoursUtc" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" -o json | sed 's/"//g')

    blobEndpoint=$( az storage account show -n "$artifactsStorageAccountName" -g "$artifactsResourceGroupName" -o json | jq -r '.primaryEndpoints.blob' )

    defaultValue=$( cat "$templateFile" | jq '.parameters._artifactsLocation.defaultValue' )

    if [[ $defaultValue != *").properties.templateLink.uri"* ]] # this should really include deployment(). but VS Code has a bug so working around that
    then #if the template is not using the templateLink.uri, then add the storage location to the parameters
        parameterJson=$( echo "$parameterJson"  | jq "{_artifactsLocation: {value: "\"$blobEndpoint$artifactsStorageContainerName/"\"}} + ." )
    fi

    parameterJson=$( echo "$parameterJson"  | jq "{_artifactsLocationSasToken: {value: \"?"$sasToken"\"}} + ." )

    artifactsStagingDirectory=$( echo "$artifactsStagingDirectory" | sed 's/\/*$//')
    artifactsStagingDirectoryLen=$((${#artifactsStagingDirectory} + 1))

    for filepath in $( find "$artifactsStagingDirectory" -type f )
    do
        relFilePath=${filepath:$artifactsStagingDirectoryLen}
        echo "Uploading file $relFilePath..."
        az storage blob upload -f $filepath --container $artifactsStorageContainerName -n $relFilePath --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" --verbose
    done

    templateUri=$blobEndpoint$artifactsStorageContainerName/$(basename $templateFile)?$sasToken

fi

# Create the resource group only if it doesn't already exist
targetResourceGroup=$( az group list -o json | jq -r '.[] | select(.name == '\"$resourceGroupName\"')'.name )
if [[ -z $targetResourceGroup ]]
then
    az group create -n "$resourceGroupName" -l "$location"
fi

# Remove line endings from parameter JSON so it can be passed in to the CLI as a single line
parameterJson=$( echo "$parameterJson" | jq -c '.' )

if [[ $validateOnly ]]
then
    if [[ $uploadArtifacts || $_artifactsLocationParameter != null ]]
    then
        az deployment group validate -g "$resourceGroupName" --template-uri $templateUri --parameters "$parameterJson" --verbose
    else
        az deployment group validate -g "$resourceGroupName" --template-file $templateFile --parameters "$parameterJson" --verbose
    fi
else
    if [[ $uploadArtifacts || $_artifactsLocationParameter != null ]]
    then
        az deployment group create -g "$resourceGroupName" -n AzureRMSamples --template-uri $templateUri --parameters "$parameterJson" --verbose
    else
        az deployment group create -g "$resourceGroupName" -n AzureRMSamples --template-file $templateFile --parameters "$parameterJson" --verbose
    fi
fi
