---
description: This template deploys CKAN using Apache Solr (for search) and PostgreSQL (database) on an Ubuntu VM. CKAN, Solr and PostgreSQL are deployed as individual Docker containers on the VM.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: docker-ckan
languages:
- json
---
# Deploy CKAN

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/ckan/docker-ckan/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/ckan/docker-ckan/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/ckan/docker-ckan/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/ckan/docker-ckan/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/ckan/docker-ckan/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/ckan/docker-ckan/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fckan%2Fdocker-ckan%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fckan%2Fdocker-ckan%2Fazuredeploy.json)

This template allows you to deploy an Ubuntu Server 15.04 VM with
Docker (using the [Docker Extension](https://github.com/Azure/azure-docker-extension)) and start a CKAN container
listening an port 80 alongside solr and postgresql containers that are
linked to the CKAN application.

NOTE: this template is currently unsuitable for production use as the
PostgreSQL container uses a default username and password.

The configuration is defined using the [Docker Compose](https://docs.docker.com/compose)
capabilities of the [Azure Docker Extension](https://github.com/Azure/azure-docker-extension).

See the [CKAN documentation](http://docs.ckan.org/en/latest/maintaining/installing/index.html?highlight=docker) for more information
about this deployment method.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, DockerExtension`
