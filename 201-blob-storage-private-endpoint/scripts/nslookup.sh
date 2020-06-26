#!/bin/bash

# Variables
adlsServicePrimaryEndpoint=$1
blobServicePrimaryEndpoint=$2

# Parameters validation
if [[ -z $adlsServicePrimaryEndpoint ]]; then
    echo "adlsServicePrimaryEndpoint parameter cannot be null or empty"
    exit 1
fi

if [[ -z $blobServicePrimaryEndpoint ]]; then
    echo "blobServicePrimaryEndpoint parameter cannot be null or empty"
    exit 1
fi

# Eliminate debconf: warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Run nslookup to verify that the <storage-account>.dfs.core.windows.net public hostname of the storage account 
# is properly mapped to <storage-account>.privatelink.dfs.core.windows.net by the privatelink.dfs.core.windows.net 
# private DNS zone and the latter is resolved to the private address by the A record
nslookup $adlsServicePrimaryEndpoint

# Run nslookup to verify that the <storage-account>.blob.core.windows.net public hostname of the storage account 
# is properly mapped to <storage-account>.privatelink.blob.core.windows.net by the privatelink.blob.core.windows.net 
# private DNS zone and the latter is resolved to the private address by the A record
nslookup $blobServicePrimaryEndpoint