# Add an NSG with security rules to an existing subnet

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-nsg-for-redis/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-nsg-for-redis/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-nsg-for-redis/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-nsg-for-redis/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-nsg-for-redis/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-nsg-for-redis/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvnet-nsg-for-redis%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvnet-nsg-for-redis%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvnet-nsg-for-redis%2Fazuredeploy.json)

`Tags: redis, cache, vnet, nsg`

## Notes
If an NSG with the same name and resource group already exists, it will be replaced with the new NSG. All existing security rules in the old NSG will be lost. If other subnets are associated with the NSG, they will remain associated with the new NSG and its new security rules.

The VNet and NSG must be located in the same region to be associated. The VNet and NSG do not have to be in the same resource group.

## Solution overview and deployed resources
This template deploys a Network Security Group. The NSG is preconfigured with security rules to allow Azure Redis Cache to operate within an existing Virtual Network.

The following resources are deployed as part of the solution

#### Network Security Groups
This template deployes a Network Security Group

+ **Microsoft.Network/networkSecurityGroups**: the new Network Security Group with preconfigured Azure Redis Cache security rules

#### Virtual Networks
This template associates the new NSG with an existing subnet within an existing Virtual Network in the same region

+ **Microsoft.Network/virtualNetworks**: an existing Virtual Network and subnet

## Prerequisites
An existing Virtual Network and subnet is required before deploying this template. Learn more about the VNet requirements for Azure Redis Cache [here](https://docs.microsoft.com/en-us/azure/redis-cache/cache-how-to-premium-vnet). The provided prerequisite templates may be used to deploy the required VNet.

## Deployment steps
You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.


