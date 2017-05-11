#!/bin/bash

#
# Uploads the HANA Express Setup .tgz file to an Azure Storage Account and
# creates a shared access signature that can be used for launching the quick start deployment
#

resGroupName=$1
storageAccountName=${2,,}   # ToLowerCase the storage account name
containerName=${3,,}        # ToLowerCase the container name
location=$4
localHxeUrl=$5

#
# Only continue if the local file exists
#
if [ ! -f "$localHxeUrl" ]; then
    echo "Local HXE Setup TAR-archive with name $localHxeUrl does not exist. Please download the file to your local machine and specify the full path to the HANA Express TAR Setup archive (i.e. ~/hxe.tgz) archive!"
    exit -10
fi

#
# First, try to get the storage account with the name specified above
#
echo "Checking if storage account $storageAccountName exists in resource group $resGroupName..."
foundAccount=`az storage account show --name="$storageAccountName" --resource-group="$resGroupName" --output=tsv`
if [ "$foundAccount"  == "" ]; then
    echo "Storage account does not exist, creating one..."
    az storage account create --name="$storageAccountName" --resource-group="$resGroupName" --location="$location" --sku="Standard_LRS"
else
    echo "Storage account found!"
fi
echo "Retrieving storage account connection string..."
accountConnString=`az storage account show-connection-string --name="$storageAccountName" --resource-group="$resGroupName" --output=tsv`

#
# Create a container if needed
#
echo "Checking if container $containerName exists in Storage Account $storageAccountName..."
containerExists=`az storage container exists --name="$containerName" --connection-string="$accountConnString" --output=tsv`
if [ "$containerExists" != "True" ]; then
    echo "Container does not exist, creating it..."
    az storage container create --name="$containerName" --connection-string="$accountConnString"
else
    echo "Container exists, using it!"
fi

#
# Now upload the HXE setup package to the storage container
#
echo "Uploading HANA setup package '$localHxeUrl' to storage container $containerName on storage account $storageAccountName..."
fileNameOnly=`basename "$localHxeUrl"`     # Get the pure file name for the local tar archive with HXE setup files
fileNameOnly=${fileNameOnly,,}              # Lower-case the file name
existingBlob=`az storage blob exists --connection-string="$accountConnString" --container-name="$containerName" --name="$fileNameOnly"`
if [ "$existingBlob" != "True" ]; then
    echo "Uploading $fileNameOnly since file not uploaded, yet!"
    az storage blob upload --connection-string="$accountConnString" --container-name="$containerName" --name="$fileNameOnly" --file="$localHxeUrl"
else
    echo "Blob does exist, already. Skipping upload!"
fi
echo "Upload completed!"

#
# Finally we need a shared access signature for the blob just uploaded to the storage account
#
storageSas=`az storage blob generate-sas --connection-string="$accountConnString" --containerName="$containerName" --name="$fileNameOnly" --permissions=r --output=tsv`
echo "Created shared access storage signature. Please use this for downloading the file!"
echo $storageSas

echo "Now creating sample azuredeploy.sample.parameters.json..."
cat azuredeploy.parameters.json \
| sed -e "s/urltohxetgzdownload/$storageSas" \
>> azuredeploy.sample.parameters.json
echo "azuredeploy.sample.parameters.json with corret SAS-URL generated."
echo "Please adjust the other parameters in this file."
echo "Then continue with az group create and az group deployment create!"
echo "Thank You!"