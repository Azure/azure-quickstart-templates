#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2021 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Variables
privateDnsZoneName=$1
vmName1=$2
vmName2=$3
adlsServicePrimaryEndpoint=$4
blobServicePrimaryEndpoint=$5
fileSystemName=${HOSTNAME,,}
directoryName="documents"
fileName="${HOSTNAME,,}.txt"
fileContent="This file was written by the $HOSTNAME virtual machine via a private endpoint."

# Parameter validation
if [[ -z $privateDnsZoneName ]]; then
    echo "privateDnsZoneName cannot be null or empty"
    exit 1
else
    echo "privateDnsZoneName        : $privateDnsZoneName"
fi

if [[ -z $vmName1 ]]; then
    echo "vmName1 cannot be null or empty"
    exit 1
else
    echo "vmName1                   : $vmName1"
fi

if [[ -z $vmName2 ]]; then
    echo "vmName2 cannot be null or empty"
    exit 1
else
    echo "vmName2                   : $vmName2"
fi

if [[ -z $adlsServicePrimaryEndpoint ]]; then
    echo "adlsServicePrimaryEndpoint cannot be null or empty"
    exit 1
else
    echo "adlsServicePrimaryEndpoint: $adlsServicePrimaryEndpoint"
fi

if [[ -z $blobServicePrimaryEndpoint ]]; then
    echo "blobServicePrimaryEndpoint cannot be null or empty"
    exit 1
else
    echo "blobServicePrimaryEndpoint: $blobServicePrimaryEndpoint"
fi

if [[ -z $fileSystemName ]]; then
    echo "fileSystemName parameter cannot be null or empty"
    exit 1
else
    echo "fileSystemName            : $fileSystemName"
fi

if [[ -z $directoryName ]]; then
    echo "directoryName parameter cannot be null or empty"
    exit 1
else
    echo "directoryName             : $directoryName"
fi

# Extract the adls storage account name from the adls service primary endpoint
# Note: when using the Azure CLI, you have to use both a blob and adls private endpoint
# because under the cover the tool uses calls to the blob REST API
storageAccountName=$(echo "$adlsServicePrimaryEndpoint" | awk -F'.' '{print $1}')

if [[ -z $storageAccountName ]]; then
    echo "storageAccountName cannot be null or empty"
    exit 1
else
    echo "storageAccountName: $storageAccountName"
fi

# Eliminate debconf: warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Install NGINX web server
sudo apt-get install -y nginx

# Change the default page of the NGINX web server
sudo echo "This is [$HOSTNAME] virtual machine" > /var/www/html/index.html

# Install curl and traceroute
sudo apt-get install -y curl traceroute

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Run nslookup to verify that the <vm-name-1>.<private-dns-zone-name> is resolved to the private IP address of the first virtual machine
echo "nslookup ${vmName1,,}.$privateDnsZoneName"
nslookup ${vmName1,,}.$privateDnsZoneName

# Call the NGINX web server on the first virtual machine
echo "curl http://${vmName1,,}.$privateDnsZoneName"
curl http://${vmName1,,}.$privateDnsZoneName

# Run nslookup to verify that the <vm-name-2>.<private-dns-zone-name> is resolved to the private IP address of the second virtual machine
echo "nslookup ${vmName2,,}.$privateDnsZoneName"
nslookup ${vmName2,,}.$privateDnsZoneName

# Call the NGINX web server on the second virtual machine
echo "curl http://${vmName2,,}.$privateDnsZoneName"
curl http://${vmName2,,}.$privateDnsZoneName

# Run nslookup to verify that the <storage-account>.dfs.core.windows.net public hostname of the storage account
# is properly mapped to <storage-account>.privatelink.dfs.core.windows.net by the privatelink.dfs.core.windows.net
# private DNS zone and the latter is resolved to the private address by the A record
echo "nslookup $adlsServicePrimaryEndpoint"
nslookup $adlsServicePrimaryEndpoint

# Run nslookup to verify that the <storage-account>.blob.core.windows.net public hostname of the storage account
# is properly mapped to <storage-account>.privatelink.blob.core.windows.net by the privatelink.blob.core.windows.net
# private DNS zone and the latter is resolved to the private address by the A record
echo "nslookup $blobServicePrimaryEndpoint"
nslookup $blobServicePrimaryEndpoint

# Login using the virtual machine system-assigned managed identity
az login --identity

# Create file system for the Azure Data Lake Storage Gen2 account
echo "Checking if the $fileSystemName file system already exists in the $storageAccountName storage account..."
name=$(az storage fs show \
    --name $fileSystemName \
    --account-name $storageAccountName \
    --auth-mode login \
    --query name \
    --output tsv 2>/dev/null)

if [[ -z $name ]]; then
    echo "The $fileSystemName file system does not exist in the $storageAccountName storage account"
    echo "Creating the $fileSystemName file system in the $storageAccountName storage account..."

    az storage fs create \
        --name $fileSystemName \
        --account-name $storageAccountName \
        --auth-mode login

    if [[ $? == 0 ]]; then
        echo "The $fileSystemName file system was successfully created in the $storageAccountName storage account"
    else
        echo "Failed to create the $fileSystemName file system in the $storageAccountName storage account"
        exit
    fi
else
    echo "The $fileSystemName file system already exists in the $storageAccountName storage account"
fi

# Create a directory in the ADLS Gen2 file system
echo "Checking if the $directoryName directory exists in the $fileSystemName file system under the $storageAccountName storage account..."
name=$(az storage fs directory show \
    --file-system $fileSystemName \
    --name $directoryName \
    --account-name $storageAccountName \
    --auth-mode login \
    --query name \
    --output tsv 2>/dev/null)

if [[ -z $name ]]; then
    echo "The $directoryName directory does not exist in the $fileSystemName file system under the $storageAccountName storage account"
    echo "Creating the $directoryName directory in the $fileSystemName file system under the $storageAccountName storage account..."

    az storage fs directory create \
        --file-system $fileSystemName \
        --name $directoryName \
        --account-name $storageAccountName \
        --auth-mode login

    if [[ $? == 0 ]]; then
        echo "The directoryName directory was successfully created in the $fileSystemName file system under the $storageAccountName storage account"
    else
        echo "Failed to create the $directoryName directory in the $fileSystemName file system under the $storageAccountName storage account"
        exit
    fi
else
    echo "The $directoryName directory already exists in the $fileSystemName file system under the $storageAccountName storage account"
fi

# Create a file to upload to the ADLS Gen2 file system in the storage account
echo "$fileContent" >$fileName

# Upload the file to a file path in ADLS Gen2 file system.
echo "Uploading the $filename file to the $directoryName directory in the $fileSystemName file system under the $storageAccountName storage account..."
az storage fs file upload \
    --file-system $fileSystemName \
    --path "$directoryName/$fileName" \
    --source "./$fileName" \
    --account-name $storageAccountName \
    --overwrite true \
    --auth-mode login

if [[ $? == 0 ]]; then
    echo "The $filename file was successfully uploaded to the $directoryName directory in the $fileSystemName file system under the $storageAccountName storage account"
else
    echo "Failed to upload the $filename file to the $directoryName directory in the $fileSystemName file system under the $storageAccountName storage account"
    exit
fi

# List files and directories in the directory in the ADLS Gen2 file system.
echo "Listing the files inside the $directoryName directory in the $fileSystemName file system under the $storageAccountName storage account..."
az storage fs file list \
    --file-system $fileSystemName \
    --path $directoryName \
    --account-name $storageAccountName \
    --auth-mode login
