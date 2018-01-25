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

azure config mode arm

if [[ $uploadArtifacts ]]
then
    
    if [[ -z $storageAccountName ]]
    then    

        subscriptionId=$( azure account show --json | jq -r '.[0].id' )
        subscriptionId="${subscriptionId//-/}" 
        subscriptionId="${subscriptionId:0:19}"
        artifactsStorageAccountName="stage$subscriptionId"
        artifactsResourceGroupName="ARM_Deploy_Staging"    

        if [[ -z $( azure storage account list --json | jq -r '.[].name | select(. == '\"$artifactsStorageAccountName\"')' ) ]]
        then
            azure group create "$artifactsResourceGroupName" "$location"
            azure storage account create -l "$location" --type "LRS" -g "$artifactsResourceGroupName" "$artifactsStorageAccountName" 2>/dev/null
        fi
    else
        artifactsResourceGroupName=$( azure storage account list --json | jq -r '.[] | select(.name == '\"$s\"') .resourceGroup' )
        if [[ -z $artifactsResourceGroupName ]] 
        then
            echo "Cannot find storageAccount: "$storageAccountName
        fi   
    fi
    
    artifactsStorageContainerName=${resourceGroupName}"-stageartifacts"
    artifactsStorageContainerName=$( echo "$artifactsStorageContainerName" | awk '{print tolower($0)}')
    
    artifactsStorageAccountKey=$( azure storage account keys list -g "$artifactsResourceGroupName" "$artifactsStorageAccountName" --json | jq -r '.[0].value' )
    azure storage container create --container "$artifactsStorageContainerName" -p Off -a "$artifactsStorageAccountName" -k "$artifactsStorageAccountKey" >/dev/null 2>&1
    
    # Get a 4-hour SAS Token for the artifacts container. Fall back to OSX date syntax if Linux syntax fails.
    plusFourHoursUtc=$(date -u -v+4H +%Y-%m-%dT%H:%M:%S%z 2>/dev/null) || plusFourHoursUtc=$(date -u --date "$dte 4 hour" --iso-8601=seconds)

    sasToken=$( azure storage container sas create --container "$artifactsStorageContainerName" --permissions r --expiry "$plusFourHoursUtc" -a "$artifactsStorageAccountName" -k "$artifactsStorageAccountKey" --json | jq -r '.sas' )

    blobEndpoint=$( azure storage account show "$artifactsStorageAccountName" -g "$artifactsResourceGroupName" --json | jq -r '.primaryEndpoints.blob' )

    parameterJson=$( echo "$parameterJson"  | jq "{_artifactsLocation: {value: "\"$blobEndpoint$artifactsStorageContainerName"\"}, _artifactsLocationSasToken: {value: \"?"$sasToken"\"}} + ." )

    artifactsStagingDirectory=$( echo "$artifactsStagingDirectory" | sed 's/\/*$//')
    artifactsStagingDirectoryLen=$((${#artifactsStagingDirectory} + 1))

    for filepath in $( find "$artifactsStagingDirectory" -type f )
    do
        relFilePath=${filepath:$artifactsStagingDirectoryLen}
        azure storage blob upload -f $filepath --container $artifactsStorageContainerName -b $relFilePath -q -a "$artifactsStorageAccountName" -k "$artifactsStorageAccountKey"
    done 
fi

azure group create "$resourceGroupName" "$location"

# Remove line endings from parameter JSON so it can be passed in to the CLI as a single line
parameterJson=$( echo "$parameterJson" | jq -c '.' )

if [[ $validateOnly ]]
then
    azure group template validate -g "$resourceGroupName" -f $templateFile -p "$parameterJson" -v
else
    azure group deployment create -g "$resourceGroupName" -n AzureRMSamples -f $templateFile -p "$parameterJson" -v
fi