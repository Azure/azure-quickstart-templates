---
description: This template allows you to deploy a confidential Windows VM Scale Set with confidential OS disk encryption enabled.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmss-windows-cvm-fde
languages:
- json
---
# Deploy a confidential Windows VM Scale Set with confidential OS disk encryption

[![Deploy To Azure](https://raw.githubusercontent.com/deepaksh-microsoft/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdeepaksh-microsoft%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-windows-cvm-fde%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fdeepaksh-microsoft%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-windows-cvm-fde%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/deepaksh-microsoft/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdeepaksh-microsoft%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmss-windows-cvm-fde%2Fazuredeploy.json)

This template allows you to deploy a confidential Windows VM Scale Set with confidential OS disk encryption enabled. Know more about Confidential OS disk encryption: https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-vm-overview#confidential-os-disk-encryption

## Prerequisites

To know about the VM sizes, OS and regions available for Confidential VMs, refer to: https://learn.microsoft.com/en-us/azure/confidential-computing/confidential-vm-overview#limitations 

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachineScaleSets`
