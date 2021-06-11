# Create a Storage Spaces Direct (S2D) Scale-Out File Server (SOFS) Cluster with Windows Server 2016 on an existing VNET

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-ha-pxc-zones/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-ha-pxc-zones/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-ha-pxc-zones/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-ha-pxc-zones/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-ha-pxc-zones/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mysql/mysql-ha-pxc-zones/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmysql%2Fmysql-ha-pxc-zones%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmysql%2Fmysql-ha-pxc-zones%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmysql%2Fmysql-ha-pxc-zones%2Fazuredeploy.json)

This template lets you create a 3 node Percona XtraDB Cluster 5.6 on Azure.  It's tested on Ubuntu 12.04 LTS and CentOS 6.5.  

To verify the cluster, type in "mysql -h your_public_ip_dns_name -u test -p".  The password is what you set for sstuser in my.cnf. Run MySQL command "show status like 'wsrep%'".  You should see that wsrep_cluster_size is 3 by default and wsrep_ready is "ON". 

To gain root access to MySQL, you must ssh into a node and sudo to run mysql.   



