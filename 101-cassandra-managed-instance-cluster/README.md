# Create an Azure Managed Instance for Apache Cassandra cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-cluster%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-cluster%2Fazuredeploy.json) 

This template creates an Azure Managed Instance for Apache Cassandra cluster, with a single data-center in one region.

Below are the parameters which can be user configured in the parameters file including:

- **name:** Name of the cluster
- **location:** Enter locations for the region, e.g. "West US"
- **initialCassandraAdminPassword:** Enter an admin password for the cluster.
- **delegatedSubnetId:** ARM resource id of a subnet that this cluster's NICs should be attached to.
- **nodeCount:** Desired number of nodes for the data-center that will be created in the cluster