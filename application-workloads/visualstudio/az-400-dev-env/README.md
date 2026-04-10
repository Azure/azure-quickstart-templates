---
description: VM with VS2017 Community, Docker-desktop, Git and VS Code for AZ-400 (Azure DevOps) Labs
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: az-400-dev-env
languages:
- json
---
# Dev Environment for AZ-400 Labs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/az-400-dev-env/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/az-400-dev-env/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/az-400-dev-env/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/az-400-dev-env/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/az-400-dev-env/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/az-400-dev-env/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Faz-400-dev-env%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Faz-400-dev-env%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Faz-400-dev-env%2Fazuredeploy.json)

Template for setting up environment for AZ-400 (Azure DevOps Certification) Labs.

## Applications Installed

- Visual Studio CODE
- Visual Studio 2022 Latest Community Edition
- Git for Windows
- Docker Desktop
- Microsoft Edge Web browser
- DBeaver (Universal SQL Client ) *NEW*
- MobaXTerm (Multi-tabbed SSH Client) *NEW*

At your first login, docker-desktop will start preparing a Linux VM for docker. It might take 5 minutes. Thereafter it should start on every login within few seconds.

> Please be patient, VM Provisioning would take about 30 minutes !

## Issue with Docker desktop 

You must configure docker desktop to use `Hyper-V` instead of `WSL` for linux containers

![Docker desktop](./docker-issue.png)


`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScriptExtension`
