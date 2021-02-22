# Create an Azure Managed Instance for Apache Cassandra hybrid cluster

<!-- ![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/PublicDeployment.svg) -->

<!-- ![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/FairfaxDeployment.svg) -->

<!-- ![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-cassandra-managed-instance-cluster/CredScanResult.svg) -->

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-cluster%2Fazuredeploy.json)
<!-- [![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-cluster%2Fazuredeploy.json) -->
<!-- [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-managed-instance-cluster%2Fazuredeploy.json)  -->

This template creates an Azure Managed Instance for Apache Cassandra cluster. In addition, it defines external seed nodes, external public certificates, and external gossip certificates that you want your new data-centers to connect to as part of a hybrid cluster. The cluster name specificed in "name" (or "overrideClusterName" if not a valid ARM name) should be the same as your existing cluster.

Below are the parameters which can be user configured in the parameters file including:

- **name:** Name of your existing on-premises or self-hosted cluster. In case the name of your existing cluster is not permitted in Azure, add the closest name possible here (you ca enter the full name in "overrideClusterName").
- **location:** Enter locations for the region, e.g. "West US".
- **initialCassandraAdminPassword:** Enter an admin password for the cluster.
- **delegatedSubnetId:** ARM resource id of a subnet that this cluster's NICs should be attached to.
- **cassandraVersion:** The Apache Cassandra version across the cluster (should be the same major version as your existing cluster)
- **hoursBetweenBackups:** The number of hours between backups that the service will take of your managed Cassandra data-centers
- **overrideClusterName:** Name of your existing on-premises or self-hosted cluster (you should always add this value, but in the case where your cluster name is not a valid name for Azure resources, the full name of your existing cluster will be here)