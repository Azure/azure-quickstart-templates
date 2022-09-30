---
description: This template disables encryption on a running Linux vm 
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: decrypt-running-linux-vm
languages:
- json
---
# Disable encryption on a running Linux VM.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/decrypt-running-linux-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/decrypt-running-linux-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/decrypt-running-linux-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/decrypt-running-linux-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/decrypt-running-linux-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/decrypt-running-linux-vm/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fdecrypt-running-linux-vm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fdecrypt-running-linux-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fdecrypt-running-linux-vm%2Fazuredeploy.json)

This template disables encryption on a running Linux VM . This template assumes that the VM is located in the same region as the resource group. If not, please edit the template to pass the appropriate location for the VM sub-resources.

References:

- [White paper](https://azure.microsoft.com/documentation/articles/azure-security-disk-encryption/)
- [Explore Azure Disk Encryption with Azure Powershell](https://blogs.msdn.microsoft.com/azuresecurity/2015/11/16/explore-azure-disk-encryption-with-azure-powershell/)
- [Explore Azure Disk Encryption with Azure PowerShell – Part 2](http://blogs.msdn.com/b/azuresecurity/archive/2015/11/21/explore-azure-disk-encryption-with-azure-powershell-part-2.aspx)

`Tags:Microsoft.Compute/virtualMachines/extensions, AzureDiskEncryptionForLinux, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, [variables('extensionName')]`
