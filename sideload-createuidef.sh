#!/bin/bash -e
while getopts "a:l:s:f:g" opt; do
    case $opt in
        a)
            artifactsStagingDirectory='.' #the folder for the createUIDefinition.json file
        ;;
        l)
            storageLocation=$OPTARG #location for the staging storage account if it needs to be created
        ;;
        s)
            storageContainerName='createuidef' #storage container for staging the file
        ;;
        f)
            createUIDefFile='createUIDefinition.json'
        ;;
        g)
            gov='false'
        ;;
    esac
done
    
    # if [[ -z $storageAccountName ]]
    # then    

subscriptionId=$( az account show -o json | jq -r '.id' )
subscriptionId="${subscriptionId//-/}" 
subscriptionId="${subscriptionId:0:19}"
artifactsStorageAccountName="stage$subscriptionId"
artifactsResourceGroupName="ARM_Deploy_Staging"    

echo "check storage account"
if [[ -z $( az storage account list -o json | jq -r '.[].name | select(. == '\"$artifactsStorageAccountName\"')' ) ]]
then
    if [[ -z $storageLocation ]] 
    then
        echo "-l (storageLocation) must be specified when storageAccount needs to be created, usually on first run for a subscription."
        exit 1
    fi
    az group create -n "$artifactsResourceGroupName" -l "$storageLocation"
    az storage account create -l "$storageLocation" --sku "Standard_LRS" -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" 2>/dev/null
fi

    # else
    #     artifactsStorageAccountName=$storageAccountName
    #     artifactsResourceGroupName=$( az storage account list -o json | jq -r '.[] | select(.name == '\"$storageAccountName\"') .resourceGroup' )
    #     if [[ -z $artifactsResourceGroupName ]] 
    #     then
    #         echo "Cannot find storageAccount: "$storageAccountName
    #     fi   
    # fi


    artifactsStorageContainerName=${storageContainerName}"-stageartifacts"
    artifactsStorageContainerName=$( echo "$storageContainerName" | awk '{print tolower($0)}')

echo "get key"  
    artifactsStorageAccountKey=$( az storage account keys list -g "$artifactsResourceGroupName" -n "$artifactsStorageAccountName" -o json | jq -r '.[0].value' )
echo $artifactsStorageAccountKey
echo "create container $storageContainerName - $artifactsStorageAccountName"
    az storage container create -n "$storageContainerName" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" # >/dev/null 2>&1
    
echo "updload file"
    #upload file
    echo $artifactsStagingDirectory'\'$createUIDefFile
    az storage blob upload -f $artifactsStagingDirectory'\'$createUIDefFile --container $storageContainerName -n $relFilePath --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" --verbose

exit 1




    # Get a 1-hour SAS Token for the artifacts container. Fall back to OSX date syntax if Linux syntax fails.
    plusFourHoursUtc=$(date -u -v+4H +%Y-%m-%dT%H:%MZ 2>/dev/null)  || plusFourHoursUtc=$(date -u --date "$dte 1 hour" +%Y-%m-%dT%H:%MZ)

    sasToken=$( az storage container generate-sas -n "$storageContainerName" --permissions r --expiry "$plusFourHoursUtc" --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" -o json | sed 's/"//g')

#    $uidefurl = New-AzureStorageBlobSASToken -Container $StorageContainerName -Blob (Split-Path $createUIDefFile -leaf) -Context $storageAccount.Context -FullUri -Permission r   
#    $encodedurl = [uri]::EscapeDataString($uidefurl)

    blobEndpoint=$( az storage account show -n "$artifactsStorageAccountName" -g "$artifactsResourceGroupName" -o json | jq -r '.primaryEndpoints.blob' )
    uidefurl = $blobEndpoint$storageContainerName

    parameterJson=$( echo "$parameterJson"  | jq "{_artifactsLocation: {value: "\"$blobEndpoint$storageContainerName"\"}, _artifactsLocationSasToken: {value: \"?"$sasToken"\"}} + ." )

    artifactsStagingDirectory=$( echo "$artifactsStagingDirectory" | sed 's/\/*$//')
    artifactsStagingDirectoryLen=$((${#artifactsStagingDirectory} + 1))

    for filepath in $( find "$artifactsStagingDirectory" -type f )
    do
        relFilePath=${filepath:$artifactsStagingDirectoryLen}
        echo "Uploading file $relFilePath..."
        az storage blob upload -f $filepath --container $artifactsStorageContainerName -n $relFilePath --account-name "$artifactsStorageAccountName" --account-key "$artifactsStorageAccountKey" --verbose
    done

    templateUri=$blobEndpoint$artifactsStorageContainerName/$(basename $templateFile)?$sasToken







exit 1

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
    if [[ $uploadArtifacts ]]
    then
        az group deployment validate -g "$resourceGroupName" --template-uri $templateUri --parameters "$parameterJson" --verbose
    else
        az group deployment validate -g "$resourceGroupName" --template-file $templateFile --parameters "$parameterJson" --verbose
    fi
else
    if [[ $uploadArtifacts ]]
    then
        az group deployment create -g "$resourceGroupName" -n AzureRMSamples --template-uri $templateUri --parameters "$parameterJson" --verbose
    else
        az group deployment create -g "$resourceGroupName" -n AzureRMSamples --template-file $templateFile --parameters "$parameterJson" --verbose
    fi
fi
