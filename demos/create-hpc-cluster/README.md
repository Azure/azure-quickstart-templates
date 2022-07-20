---
description: This template creates an HPC cluster with the latest version of HPC Pack 2012 R2. The head node with local HPC databases acts as domain controller as well.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-hpc-cluster
languages:
- json
---
# Create an HPC cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/create-hpc-cluster/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/create-hpc-cluster/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/create-hpc-cluster/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/create-hpc-cluster/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/create-hpc-cluster/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/create-hpc-cluster/CredScanResult.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcreate-hpc-cluster%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fcreate-hpc-cluster%2Fazuredeploy.json)

This template allows you to create an HPC cluster with Windows compute nodes. You can choose HPC Pack 2012 R2 Compute Node image or HPC Pack 2012 R2 Compute Node with Excel image to deploy compute nodes.

`Tags: Microsoft.Resources/deployments, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, DSC, HpcVmDrivers, Microsoft.Network/networkInterfaces, LinuxNodeAgent, Microsoft.Storage/storageAccounts, Microsoft.Network/virtualNetworks, Microsoft.Compute/availabilitySets, CustomScriptExtension, Microsoft.Network/publicIPAddresses`
