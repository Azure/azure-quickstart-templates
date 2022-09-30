---
description: This template allows you to deploy an Ubuntu VM with Docker installed (using the Docker Extension) and an Open Source Parse Server container created and configured to replace the (now sunset) Parse service.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: docker-parse
languages:
- json
---
# Deploy an Open-Source Parse Server with Docker

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/parse/docker-parse/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/parse/docker-parse/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/parse/docker-parse/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/parse/docker-parse/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/parse/docker-parse/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/parse/docker-parse/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fparse%2Fdocker-parse%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fparse%2Fdocker-parse%2Fazuredeploy.json)
	

This template allows you to deploy an Ubuntu Server 15.10 VM with Docker (using the [Docker Extension](https://github.com/Azure/azure-docker-extension))
and starts an open-source Parse server container listening on port 80. For information [regarding the Parse Server image, please see the repository](https://github.com/felixrieseberg/parse-docker).

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, DockerExtension`
