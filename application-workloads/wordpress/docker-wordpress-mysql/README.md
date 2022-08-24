---
description: This template allows you to deploy an Ubuntu VM with Docker installed (using the Docker Extension) and WordPress/MySQL containers created and configured to serve a blog server.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: docker-wordpress-mysql
languages:
- json
---
# Deploy a WordPress blog with Docker

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fdocker-wordpress-mysql%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fdocker-wordpress-mysql%2Fazuredeploy.json)

This template allows you to deploy an Ubuntu Server 18.04-LTS VM with Docker (using the [Docker Extension](https://github.com/Azure/azure-docker-extension))
and starts a WordPress container listening an port 80 which uses MySQL database running
in a separate but linked Docker container, which are created using [Docker Compose](https://docs.docker.com/compose)
capabilities of the [Azure Docker Extension](https://github.com/Azure/azure-docker-extension).

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, DockerExtension`
