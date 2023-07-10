---
description: This template creates mesh network topology with Azure Virtual Network Manager. It contains a virtual network manager instance, a hub virtual network, and multiple spoke virtual networks. It will deploy a connectivity configuration for all production virtual networks using dynamic membership.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: virtual-network-manager-mesh
languages:
- json
---

# Create a mesh network with Azure Virtual Network Manager

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/CredScanResult.svg)

```
If the sample includes a main.bicep file:
```

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/path-to-sample/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json)

```

To add a createUiDefinition.json file to the deploy button, append the url to the createUiDefinition.json file to the href for the button, e.g.

https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpath-to-sample%2FcreateUiDefinition.json

Note the url is case sensitive.

```

This template creates a mesh network topology with Azure Virtual Network Manager. It contains a virtual network manager instance, a hub virtual network, and multiple spoke virtual networks. It will deploy a connectivity configuration for all production virtual networks using dynamic membership. To learn more about how to deploy the template, see the [quickstart](https://learn.microsoft.com/azure/virtual-network-manager/create-virtual-network-manager-template) article.

For more information on managing **virtual networks** with **Azure Virtual Network Manager** see:

- [What is Azure Virtual Network Manager](https://learn.microsoft.com/azure/virtual-network-manager/overview)
- [Configuring Azure Policy with network groups in Azure Virtual Network Manager](https://learn.microsoft.com/azure/virtual-network-manager/concept-azure-policy-integration)

## Deployed resources

The following resources are deployed as part of the solution.

### Microsoft.Network

Description Resource Provider 1

- **virtualNetworks**: Virtual network for NAT gateway and virtual machine.
  - **subnets**: Subnet for virtual network for NAT gateway and virtual machine.
- **networkManagers**: Description Resource type 1B
  - **networkGroups**:
  - **connectivityConfigurations**:   
- **Resource type 1C**: Description Resource type 1C

### Microsoft.Resources

Description Resource Provider 2

- **resourceGroups**: Description Resource type 2A
- **deployments**: Description Resource type 2B
- **deploymentScripts**: 

### Microsoft.Authorization

Description Resource Provider 3

- **policyAssignments**: Policy assignment for virtual network manager.
- **policyDefinitions**: Description Resource type 3B

### Microsoft.ManagedIdentity

- **userAssignedIdentities**

## Prerequisites

- To modify dynamic network groups, you must be [granted access via Azure RBAC role](concept-network-groups.md#network-groups-and-azure-policy) assignment only. Classic Admin/legacy authorization is not supported.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

How to connect to the solution

#### Management

How to manage the solution

## Notes

Solution notes

`Tags: virtual network, vnet, nat, nat gateway, virtual machine, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/publicIPPrefixes, Microsoft.Compute/virtualMachines, Microsoft.Network/virtualNetworks, Microsoft.Network/natGateways, Microsoft.Network/virtualNetworks/subnets, Microsoft.Network/networkInterfaces`
