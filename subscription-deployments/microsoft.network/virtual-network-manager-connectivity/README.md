---
description: This template deploys an Azure Virtual Network Manager and sample virtual networks into the named resource group. It supports multiple connectivity topologies and network group membership types.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: virtual-network-manager-connectivity
languages:
- bicep
- json
---
# Create an Azure Virtual Network Manager and sample VNETs

This sample demonstrates using Bicep to deploy Azure Virtual Network Manager and example Virtual Networks with different connectivity topology and network group membership types. Use deployment parameters to specify the type of configuration to deploy.

In order to support deploying Azure Policy for dynamic group membership, this sample is designed to deploy at the subscription scope. However, this is not a requirement for Azure Virtual Network Manager if using static group membership.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fmicrosoft.network%2Fvirtual-network-manager-connectivity%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fmicrosoft.network%2Fvirtual-network-manager-connectivity%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fmicrosoft.network%2Fvirtual-network-manager-connectivity%2Fazuredeploy.json)

## Solution deployment parameters

| Parameter | Type | Description | Default |
|---|---|---|--|
| `location` | string | Deployment location. Location must support availability zones. | `eastus` |
| `resourceGroupName` | string | The name of the resource group where AVMN will be deployed | `rg-avnm-sample` |
| `connectivityTopology` | string | Defines how spokes will connect to each other and how spokes will connect the hub. Valid values: "mesh", "hubAndSpoke", "meshWithHubAndSpoke" | `meshWithHubAndSpoke` |
| `networkGroupMembershipType` | string | Connectivity group membership type.| `static` |

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/virtual-network-manager-connectivity/BicepVersion.svg)

`Tags: `