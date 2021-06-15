# Deployment of Kibana+Elasticsearch Containers with Docker Compose

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/docker-kibana-elasticsearch/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdocker-kibana-elasticsearch%2Fazuredeploy.json)
	

This template allows you to deploy an Ubuntu Server 15.04 VM with Docker (using the [Docker Extension][ext])
and starts a Kibana container listening on port 5601 which uses Elasticsearch database running
in a separate but linked Docker container, which are created using [Docker Compose][compose]
capabilities of the [Azure Docker Extension][ext].

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose



