---
description: This template creates a selfhost integration runtime and registers it on Azure virtual machines
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vms-with-selfhost-integration-runtime
languages:
- bicep
- json
---
# Self-host Integration Runtime on Azure VMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/CredScanResult.svg)

Before deploying the template you must have the following

1. **Data Factory.** The integration runtime is created in the data factory. If you don't have a data factory,  see the [Create data factory](https://docs.microsoft.com/azure/data-factory/data-factory-move-data-between-onprem-and-cloud#create-data-factory) for steps to create one.
2. **Virtual Network.** The virtual machine will join this VNET. If you don't have one, use this tutorial, see [Create virtual network](https://docs.microsoft.com/azure/virtual-network/virtual-networks-create-vnet-arm-pportal#create-a-virtual-network) to create one.

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vms-with-selfhost-integration-runtime/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvms-with-selfhost-integration-runtime%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvms-with-selfhost-integration-runtime%2Fazuredeploy.json)

When you deploy this Azure Resource Template, you will create a logical selfhost IR in your data factory and the following resources

- Azure Virtual Machine
- Azure Storage (for VM system image and boot diagnostic)
- Public IP Address
- Network Interface
- Network Security Group

This template can help you create self-hosted IR and make it workable in azure VMs. The VM must join in an existing VNET.

The below picture can help you find how to get ![vnet and subnet information](images/vnet.png).

`Tags: Microsoft.Resources/deployments, Microsoft.Network/networkSecurityGroups, Microsoft.Storage/storageAccounts, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension, Microsoft.DataFactory/dataFactories/gateways, Microsoft.DataFactory/factories/integrationruntimes, SelfHosted, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Network/virtualNetworks, Microsoft.DataFactory/datafactories`
