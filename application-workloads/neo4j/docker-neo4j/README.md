---
description: This template allows you to deploy an Ubuntu VM with Docker installed (using the Docker Extension) and a Neo4J container which uses an external disk to store it's data.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: docker-neo4j
languages:
- json
---
# Deploy Neo4J in Docker and data on external disk.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/docker-neo4j/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/docker-neo4j/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/docker-neo4j/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/docker-neo4j/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/docker-neo4j/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/neo4j/docker-neo4j/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fneo4j%2Fdocker-neo4j%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fneo4j%2Fdocker-neo4j%2Fazuredeploy.json)

Built by: [jmspring](https://github.com/jmspring)

This template allows you to deploy an Ubuntu Server 15.04 VM with Docker (using the [Docker Extension](https://github.com/Azure/azure-docker-extension))
and starts a Neo4J instance listening on ports 7474 (non-ssl) and 7473 (ssl).  The data disk
for the Neo4J instance is an external disk mounted on the VM.  The container is created
using the [Docker Compose](https://docs.docker.com/compose) capabilities of the [Azure Docker Extension](https://github.com/Azure/azure-docker-extension).

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| vmName | The name of the VM |
| vmSize | The size of the VM |
| location | The location where the Virtual Machine will be deployed  |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScript, DockerExtension`
