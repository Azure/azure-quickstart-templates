---
description: Hazelcast is an in-memory data platform that can be used for a variety of data applications. This template will deploy any number of Hazelcast nodes and they will automatically discover each other.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: hazelcast-vm-cluster
languages:
- bicep
- json
---
# Hazelcast Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/hazelcase/hazelcast-vm-cluster/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fhazelcase%2Fhazelcast-vm-cluster%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fhazelcase%2Fhazelcast-vm-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fhazelcase%2Fhazelcast-vm-cluster%2Fazuredeploy.json)

[Hazelcast](https://hazelcast.com) is an in-memory data platform which can support a variety of data applications such as data grids, nosql data stores, caching and web session clustering.

This template will deploy any number of Ubuntu Hazelcast nodes in a vnet using the [official Hazelcast Azure Discovery Provider](https://github.com/hazelcast/hazelcast-azure). Every node is installed with Hazelcast as an [upstart service](http://upstart.ubuntu.com/) and will continue to run even after subsequent restarts. Each node will discover every other node on the network automatically so you can add and remove nodes as you see fit.

Use the **Deploy to Azure** button above to get started.

Checkout Hazelcast's [official documentation](http://hazelcast.org/documentation/) to learn more on how to use Hazelcast.

`Tags: Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, SystemAssigned, Microsoft.Authorization/roleAssignments, Microsoft.Compute/virtualMachines/extensions, CustomScript`
