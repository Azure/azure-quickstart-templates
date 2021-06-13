# Deploys a WordPress web site backed by MySQL master-slave replication

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/wordpress-mysql-replication/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/wordpress-mysql-replication/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/wordpress-mysql-replication/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/wordpress-mysql-replication/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/wordpress-mysql-replication/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/wordpress-mysql-replication/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fwordpress-mysql-replication%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fwordpress-mysql-replication%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fwordpress-mysql-replication%2Fazuredeploy.json)
  

  

This template deploys a WordPress site in Azure backed by MySQL replication with one master and one slave servers.  It has the following capabilities:

- Installs and configures GTID based MySQL replication on CentOS 6.
- Deploys a load balancer in front of the 2 MySQL VMs.  MySQL, SSH, and MySQL probe ports are exposed through the load balancer using Network Security Group rules.  WordPress accesses MySQL through the load balancer.
- Configures a http based health probe for each MySQL instance that can be used to monitor MySQL health.
- WordPress deployment starts immediately after MySQL deployment finishes.  Details about MySQL management, including failover, can be found [here](https://github.com/Azure/azure-quickstart-templates/tree/master/mysql-replication).

### How to Deploy
* This template takes a dependency on the [MySQL-replication template](https://github.com/Azure/azure-quickstart-templates/tree/master/mysql-replication). Refer to the README of MySQL-Replication template for how to customize MySQL deployment, and how to failover, backup, and restore.

License
----

MIT



