#!/bin/bash

# Get the list of resource groups that start with "bicep-"
resourceGroups=$(az group list --query "[?starts_with(name, 'bicep-')].name" -o tsv)

# Loop through each resource group and delete it
for rg in $resourceGroups; do
    echo "Deleting resource group: $rg"
    az group delete --name $rg --yes --no-wait
done

echo "All resource groups starting with 'bicep-' have been scheduled for deletion."
