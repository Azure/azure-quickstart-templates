---
description: This template provides easy to deploy SonarQube to Web App on Linux with PostgreSQL Flexible Server, VNet integration and private DNS.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: webapp-linux-sonarqube-postgresql-private-vnet
languages:
- json
- bicep
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

`Tags: Azure Web App, Azure PostgreSQL (Flexible Servers), VNet Integration, Private DNS, SonarQube, SAST`