# Create an Azure Managed Instance for Apache Cassandra datacenter

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-datacenter/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-datacenter/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-datacenter/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-datacenter/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-datacenter/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-datacenter/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-datacenter%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-datacenter%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-datacenter%2Fazuredeploy.json) 

This template creates an Azure Managed Instance for Apache Cassandra datacenter, by referencing a cluster that has already been created. 

Below are the parameters which can be user configured in the parameters file including:

- **clusterName:** Name of your existing on-premises or self-hosted cluster.
- **dataCenterLocation:** The datacenter region.
- **dataCenterName:** The datacenter name.
- **delegatedSubnetId:** ARM resource id of a subnet that this cluster's NICs should be attached to.
- **nodeCount:** The number of nodes required in the Cassandra datacenter.
- **base64EncodedYamlFragment:** Base64 encoded YAML file for configuration. 