---
description: This template creates Azure Batch simplified node communication pool without public IP addresses.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: batch-pool-no-public-ip
languages:
- json
- bicep
---
# Azure Batch pool without public IP addresses

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.batch/batch-pool-no-public-ip/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.batch%2Fbatch-pool-no-public-ip%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.batch%2Fbatch-pool-no-public-ip%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.batch%2Fbatch-pool-no-public-ip%2Fazuredeploy.json)

This module will create Azure Batch account with node management private endpoint enabled, and provision a pool without public IP addresses in a virtual network.

Following resources will be deployed:

- Azure Batch account with IP firewall configured to block public network access to Batch node management endpoint
- Virtual network with network security group to block internet outbound access
- Private endpoint to access Batch node management endpoint of the account
- DNS integration for the private endpoint using private DNS zone linked to the virtual network
- Batch pool deployed in the virtual network and without public IP addresses

## Notes

This deployment requires simplified node communication pool for Azure Batch, which is currently supported in selected regions. If the deployment failed due to private endpoint provisioning failure, please follow the document to choose supported region then retry. For more information please refer to [Simplified Node Communication pool without public IP addresses](https://learn.microsoft.com/en-us/azure/batch/simplified-node-communication-pool-no-public-ip).

`Tags: bicep, batch, pool, nodeManagement, privateEndpoint, VNET, NoPublicIP, Microsoft.Batch/batchAccounts, Microsoft.Network/privateEndpoints, Microsoft.Network/privateDnsZones`
