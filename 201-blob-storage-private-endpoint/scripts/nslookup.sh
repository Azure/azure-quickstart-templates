#!/bin/bash

# Variables
blobServicePrimaryEndpoint=$1

# Parameter validation
if [[ -z $blobServicePrimaryEndpoint ]]; then
    echo "blobServicePrimaryEndpoint parameter cannot be null or empty"
    exit 1
fi

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Run nslookup to verify that the <storage-account>.blob.core.windows.net public hostname of the storage account 
# is properly mapped to <storage-account>.privatelink.blob.core.windows.net by the private DNS zone
# and the latter mapped to the private address by the A record
nslookup $blobServicePrimaryEndpoint