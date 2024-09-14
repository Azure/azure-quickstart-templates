---
description: This template allows you to deploy a confidential VM Scale Set with confidential OS disk encryption enabled using the latest patched version of several Windows and Linux image versions.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-cvm-fde
languages:
- json
---
# Confidential VM Scale Set with confidential disk encryption

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-cvm-fde/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-cvm-fde/PublicDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-cvm-fde/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmss-cvm-fde/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-cvm-fde%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-cvm-fde%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-cvm-fde%2Fazuredeploy.json)

This template allows you to deploy a confidential VM Scale Set with confidential OS disk encryption enabled. For more information about Confidential disk encryption, see [Confidential OS disk encryption](https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-vm-overview#confidential-os-disk-encryption).

## Prerequisites

To know about the VM sizes, OS and regions availability for Confidential VMs, refer to [prerequisites](https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-vm-overview#limitations).
`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachineScaleSets`
