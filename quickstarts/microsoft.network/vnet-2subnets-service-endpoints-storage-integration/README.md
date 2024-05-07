---
description: Creates 2 new VMs with a NIC each, in two different subnets within the same VNet. Sets service endpoint on one of the subnets and secures storage account to that subnet.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vnet-2subnets-service-endpoints-storage-integration
languages:
- json
---
# 201-vnet-2subnets-service-endpoints-storage-integration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-2subnets-service-endpoints-storage-integration/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-2subnets-service-endpoints-storage-integration/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-2subnets-service-endpoints-storage-integration/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-2subnets-service-endpoints-storage-integration/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-2subnets-service-endpoints-storage-integration/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/vnet-2subnets-service-endpoints-storage-integration/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvnet-2subnets-service-endpoints-storage-integration%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvnet-2subnets-service-endpoints-storage-integration%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fvnet-2subnets-service-endpoints-storage-integration%2Fazuredeploy.json)

This template creates a new VNet with 2 subnets, a NIC in each subnet. Enables service endpoint to Storage on one of the subnets and secures a new storage account to that subnet.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Storage/storageAccounts, Microsoft.Compute/availabilitySets, Microsoft.Compute/virtualMachines`
