#!/bin/bash

# Variables
eventHubsNamespaceEndpoint=$1
blobServicePrimaryEndpoint=$2

# Parameters validation
if [[ -z $eventHubsNamespaceEndpoint ]]; then
    echo "eventHubsNamespaceEndpoint parameter cannot be null or empty"
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

# Run nslookup to verify that public hostname of the Service Bus namespace
# is properly mapped to the private address of the provate endpoint
nslookup $eventHubsNamespaceEndpoint

# Run nslookup to verify that public hostname of the Blob storage account 
# is properly mapped to the private address of the provate endpoint
nslookup $blobServicePrimaryEndpoint