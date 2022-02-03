# Deployment of WordPress+MySQL Containers with Docker Compose

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/wordpress/docker-wordpress-mysql/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fdocker-wordpress-mysql%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fwordpress%2Fdocker-wordpress-mysql%2Fazuredeploy.json)
	

This template allows you to deploy an Ubuntu Server 18.04-LTS VM with Docker (using the [Docker Extension][ext])
and starts a WordPress container listening an port 80 which uses MySQL database running
in a separate but linked Docker container, which are created using [Docker Compose][compose]
capabilities of the [Azure Docker Extension][ext].

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose
