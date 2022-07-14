---
description: This template deploys an Elasticsearch cluster on a Virtual Machine scale set. The template provisions 3 dedicated master nodes, with an optional number of data nodes, which run on managed disks.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: elasticsearch-vmss
languages:
- json
---
# Install Elasticsearch cluster on a Virtual Machine Scale Set

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-vmss/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-vmss/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-vmss/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-vmss/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-vmss/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch-vmss/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch-vmss%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch-vmss%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch-vmss%2Fazuredeploy.json)

This template deploys an Elasticsearch cluster on Virtual Machines using a Scale Set and managed disks. The template provisions 3 dedicated master nodes, which are in their own availability set with locally attached disks, while the data nodes live in a scale set and use managed disks.

X-Pack is installed on all nodes, and Kibana is installed on the Master-eligible nodes.

## Notes

Warning! X-Pack security is disabled, and HTTPS is not enabled. The load balancer allows traffic to port 5601 from all sources, so consider updating the network security group to lock this down, or enable X-Pack security, HTTPS and role-based logins.

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/loadBalancers, Microsoft.Compute/availabilitySets, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScript, Microsoft.Compute/virtualMachineScaleSets`
