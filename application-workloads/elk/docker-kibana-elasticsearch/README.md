---
description: This template allows you to deploy an Ubuntu VM with Docker installed (using the Docker Extension) and Kibana/Elasticsearch containers created and configured to serve an analytic dashboard.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: docker-kibana-elasticsearch
languages:
- json
---
# Deploy a Kibana dashboard with Docker

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json)

This template allows you to deploy an Ubuntu Server 15.04 VM with Docker (using the [Docker Extension](https://github.com/Azure/azure-docker-extension))
and starts a Kibana container listening on port 5601 which uses Elasticsearch database running
in a separate but linked Docker container, which are created using [Docker Compose](https://github.com/Azure/azure-docker-extension)
capabilities of the [Azure Docker Extension](https://github.com/Azure/azure-docker-extension).

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, DockerExtension`
