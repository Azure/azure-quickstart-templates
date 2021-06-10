# DataStax

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/datastax/datastax/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/datastax/datastax/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/datastax/datastax/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/datastax/datastax/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/datastax/datastax/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/datastax/datastax/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdatastax%2Fdatastax%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdatastax%2Fdatastax%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdatastax%2Fdatastax%2Fazuredeploy.json)



This template deploys a DataStax Enterprise (DSE) cluster to Azure running on Ubuntu virtual machines in a single datacenter.  The template can provision a cluster from 1 to 40 nodes.  Creating a greater number of nodes may cause issues with storage account I/O contention.

For the most up to date version of this template, please do not use this repo. Instead go [here](https://github.com/DSPN/azure-resource-manager-dse).  We strongly encourage use of the latest version as it incorporates bug fixes and is more flexible.

The template also provisions a storage account, virtual network and public IP addresses required by the installation.  The template will deploy to the location that the resourceGroup it is part of is located in.

The template expects the following parameters:

| Name   | Description |
|:--- |:---|
| nodeCount | Number of virtual machines to provision for the cluster |
| vmSize | Size of virtual machine to provision for the cluster |
| adminUsername  | Admin user name for the virtual machines |
| adminPassword  | Admin password for the virtual machines |

Once the Azure VMs, virtual network and storage are setup, the template installs Java and DSE on the nodes.  It also configures them.  These nodes are assigned both private and public dynamic IP addresses.

The template also sets up a node to run DataStax OpsCenter.  The script opscenter.sh installs OpsCenter and connects to the cluster by calling the OpsCenter REST API.

On completion, OpsCenter will be accessible on port 8888 of the public IP address of the OpsCenter node.


