#!/bin/bash

# Variables
keyVaultServiceEndpoint=$1
blobServicePrimaryEndpoint=$2
azureEnvironment=$3

# Parameter validation
if [[ -z $keyVaultServiceEndpoint ]]; then
    echo "keyVaultServiceEndpoint cannot be null or empty"
    exit 1
else
    echo "keyVaultServiceEndpoint: $keyVaultServiceEndpoint"
fi

if [[ -z $blobServicePrimaryEndpoint ]]; then
    echo "blobServicePrimaryEndpoint cannot be null or empty"
    exit 1
else
    echo "blobServicePrimaryEndpoint: $blobServicePrimaryEndpoint"
fi

if [[ -z $azureEnvironment ]]; then
    echo "azureEnvironment cannot be null or empty"
    exit 1
else
    echo "azureEnvironment: $keyVaultServiceEndpoint"
fi

# Extract the key vault name from the adls service primary endpoint
keyVaultName=$(echo "$keyVaultServiceEndpoint" | awk -F'.' '{print $1}')

if [[ -z $keyVaultName ]]; then
    echo "keyVaultName cannot be null or empty"
    exit 1
else
    echo "keyVaultName: $keyVaultName"
fi

# Eliminate debconf: warnings
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update the system
sudo apt-get update -y

# Upgrade packages
sudo apt-get upgrade -y

# Install jq
sudo apt-get install -y --fix-missing jq

# Install curl and traceroute
sudo apt install -y curl traceroute

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Run nslookup to verify that public hostname of the Key Vault resource
# is properly mapped to the private address of the provate endpoint
nslookup $keyVaultServiceEndpoint

# Run nslookup to verify that public hostname of the Blob storage account 
# is properly mapped to the private address of the provate endpoint
nslookup $blobServicePrimaryEndpoint

# Set cloud environment
if [[ ${azureEnvironment,,} == 'azureusgovernment' ]]; then
    az cloud set --name AzureUSGovernment
fi

# Login using the virtual machine system-assigned managed identity
az login --identity --allow-no-subscriptions

# Retrieve the list of secrets

# Create Event Hub subscription
az keyvault secret list --vault-name $keyVaultName