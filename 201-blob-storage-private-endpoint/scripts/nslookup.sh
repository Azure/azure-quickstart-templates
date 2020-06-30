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

# Eliminate debconf warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Run nslookup to verify that public hostname of the ADLS Gen 2 storage account 
# is properly mapped to the private address of the provate endpoint
nslookup $adlsServicePrimaryEndpoint

# Run nslookup to verify that public hostname of the Blob storage account 
# is properly mapped to the private address of the provate endpoint
nslookup $blobServicePrimaryEndpoint