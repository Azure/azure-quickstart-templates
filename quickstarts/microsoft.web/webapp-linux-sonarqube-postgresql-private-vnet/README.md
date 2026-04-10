---
description: This template provides easy to deploy SonarQube to Web App on Linux with PostgreSQL Flexible Server, VNet integration and private DNS.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: webapp-linux-sonarqube-postgresql-private-vnet
languages:
- bicep
- json
---
# SonarQube on Web App with PostgreSQL and VNet integration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-postgresql-private-vnet/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-linux-sonarqube-postgresql-private-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-linux-sonarqube-postgresql-private-vnet%2Fazuredeploy.json)

This template provides easy to deploy SonarQube on Web App with PostgreSQL (Flexible Servers), VNet integration and private DNS.

This approach of running SonarQube keeps communication between Sonar's App and database (Postgres) private using VNet integration and private DNS.

![SonarQube on Web App with PostgreSQL (Flexible Servers), VNet integration and private DNS](images/flexible-pg-vnet-diagram.png)

**Notice** once deployed Sonar can take a while to start due the creation of the initial empty database, it can even fail if you try to access it directly, allow to start it before accessing it or even adjust the tier for the webapp or PostgreSQL accordingly.

When deploying SonarQube using this template, it's important to note that by default, the `latest` tag is used for the SonarQube Docker image. While this ensures you always get the newest version, it can lead to unexpected upgrades and potential compatibility issues. To avoid sudden version changes that may cause SonarQube to enter maintenance mode unexpectedly, it's recommended to specify a fixed Docker image tag. This allows you to control when upgrades occur and ensure compatibility with your existing setup. You can find the list of available SonarQube Docker image tags [here](https://hub.docker.com/_/sonarqube/tags). Review the tags and select the desired version that meets your requirements, then update the template accordingly to use that specific tag instead of `latest`. By following this approach, you can maintain a stable and predictable SonarQube environment, reducing the risk of unexpected downtime or issues caused by unintended version upgrades.

`Tags: Azure Web App, Azure PostgreSQL (Flexible Servers), VNet Integration, Private DNS, SonarQube, SAST`