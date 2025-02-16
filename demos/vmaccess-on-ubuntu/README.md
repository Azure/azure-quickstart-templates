---
description: This template creates a Ubuntu VM and installs the VMAccess extension
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vmaccess-on-ubuntu
languages:
- json
---
# VMAccess extension on a Ubuntu VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmaccess-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmaccess-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmaccess-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmaccess-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmaccess-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/vmaccess-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmaccess-on-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmaccess-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fvmaccess-on-ubuntu%2Fazuredeploy.json)

This template uses the Azure Linux [VMAccess extension](https://github.com/Azure/azure-linux-extensions/tree/master/VMAccess) to deploy an Linux VM. Azure Linux VMAccess extension provides several ways to allow owner of the VM to get the SSH access back.

What you can do using the VMAccess extension:

1. Add a new user with a password or a public key.
2. Modify the password or public key of the existing user.
3. Remove the existing user.
4. Reset the ssh configuration.

How to deploy

Azure CLI or PowerShell is recommended to deploy the template.

1. Using Azure CLI

  https://azure.microsoft.com/documentation/articles/xplat-cli-azure-resource-manager/

2. Using PowerShell

  https://azure.microsoft.com/documentation/articles/powershell-azure-resource-manager/

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, VMAccessForLinux`
