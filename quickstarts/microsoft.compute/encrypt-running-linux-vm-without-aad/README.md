---
description: This template enables encryption on a running Linux VM without needing AAD application details
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: encrypt-running-linux-vm-without-aad
languages:
- json
---
# Enable encryption on a running Linux VM without AAD

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/encrypt-running-linux-vm-without-aad/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/encrypt-running-linux-vm-without-aad/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/encrypt-running-linux-vm-without-aad/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/encrypt-running-linux-vm-without-aad/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/encrypt-running-linux-vm-without-aad/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/encrypt-running-linux-vm-without-aad/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fencrypt-running-linux-vm-without-aad%2Fazuredeploy.json)  [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fencrypt-running-linux-vm-without-aad%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fencrypt-running-linux-vm-without-aad%2Fazuredeploy.json)

This template enables encryption with no AD requirement on a running Linux VM that satisfies the prerequisites listed in the [Azure Disk Encryption FAQ](https://docs.microsoft.com/azure/security/azure-security-disk-encryption-faq).

Prerequisites: Create a KeyVault in the same subscription and region as the VM

Tags: AzureDiskEncryption

References:
White paper - https://azure.microsoft.com/documentation/articles/azure-security-disk-encryption/

`Tags: Microsoft.Compute/virtualMachines/extensions, [variables('extensionName')]`
