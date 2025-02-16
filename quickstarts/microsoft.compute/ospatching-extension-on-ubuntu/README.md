---
description: This template creates a Ubuntu VM and installs the OSPatching extension
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: ospatching-extension-on-ubuntu
languages:
- json
---
# OS Patching extension on a Ubuntu VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/ospatching-extension-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/ospatching-extension-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/ospatching-extension-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/ospatching-extension-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/ospatching-extension-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/ospatching-extension-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fospatching-extension-on-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fospatching-extension-on-ubuntu%2Fazuredeploy.json)[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fospatching-extension-on-ubuntu%2Fazuredeploy.json)

Azure Linux [OSPatching extension](https://github.com/Azure/azure-linux-extensions/tree/master/OSPatching) enables the Azure VM administrators to automate the VM OS updates with the customized configurations.

This template shows a simple example to deploy OSPatching Extension on an Linux VM.

## Deploy

Azure CLI or PowerShell is recommended to deploy the template. And Azure Portal cannot ignore the optional parameters.

1. Using Azure CLI

  https://azure.microsoft.com/documentation/articles/xplat-cli-azure-resource-manager/

2. Using PowerShell

  https://azure.microsoft.com/documentation/articles/powershell-azure-resource-manager/

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, OSPatchingForLinux`
