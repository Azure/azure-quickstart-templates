---
description: This template allows you to deploy a single Octopus Deploy 3.0 server with a trial license. This will deploy on a single Windows Server 2012R2 VM (Standard D2) and SQL DB (S1 tier) into the location specified for the Resource Group.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: octopusdeploy3-single-vm-windows
languages:
- json
---
# Deploy Octopus Deploy 3.0 with a trial license.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/octopus/octopusdeploy3-single-vm-windows/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/octopus/octopusdeploy3-single-vm-windows/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/octopus/octopusdeploy3-single-vm-windows/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/octopus/octopusdeploy3-single-vm-windows/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/octopus/octopusdeploy3-single-vm-windows/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/octopus/octopusdeploy3-single-vm-windows/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Foctopus%2Foctopusdeploy3-single-vm-windows%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Foctopus%2Foctopusdeploy3-single-vm-windows%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Foctopus%2Foctopusdeploy3-single-vm-windows%2Fazuredeploy.json)

This template allows you to deploy a single Octopus Deploy 3.0 server with a trial license. This will deploy on a single Windows Server 2012R2 VM (Standard D2) and SQL DB (S1 tier) into the location specified for the Resource Group.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension, Microsoft.Sql/servers, databases, firewallrules`
