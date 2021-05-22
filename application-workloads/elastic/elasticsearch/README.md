# Install an Elasticsearch cluster on Virtual Machines

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elastic/elasticsearch/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felastic%2Felasticsearch%2Fazuredeploy.json) 

This template deploys an Elasticsearch cluster on Virtual Machines using linked templates. The template provisions 3 dedicated master nodes, with an optional number of client and data nodes, which are placed in separate availability sets and storage accounts. A load balancer is configured with a rule to route traffic on port 9200 to the client nodes, and also includes a single SSH management rule mapped to one of the client nodes or jumpbox if selected.  Multiple data disks are attached (the number depends on the size of the virtual machine selected) and data is striped across them as an approach to improve disk throughput.

The template also provides the option of deploying a standalone Marvel cluster. If selected, this option will provision 3 additional nodes of the specified size which are both master and data eligible. The data nodes are then configured to send Marvel data to these nodes, which are configured in their own cluster.    

This template deploys Virtual Machines, Storage Accounts, a Virtual Network, Availability Sets, Public IP addresses, a Load Balancer, and Network Interfaces.

An option is provided to install the cloud-azure plugin, details can be found here: http://elastic.co/blog/azure-cloud-plugin-for-elasticsearch

## Notes
Warning!  The configuration allows you to enabled external load balanced endpoints on a public IP.  The endpoint is not secure and it's recommended that you keep these endpoints internal or secure them. Elasticsearch Shield product should be considered.
