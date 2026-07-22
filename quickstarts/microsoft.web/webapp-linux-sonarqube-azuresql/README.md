---
description: This template deploys Sonarqube in an Azure App Service web app Linux container using the official Sonarqube image and backed by an Azure SQL Server.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: webapp-linux-sonarqube-azuresql
languages:
- bicep
- json
---
# Sonarqube Docker Web App on Linux with Azure SQL

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-linux-sonarqube-azuresql/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-linux-sonarqube-azuresql%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-linux-sonarqube-azuresql%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-linux-sonarqube-azuresql%2Fazuredeploy.json)

This template deploys Sonarqube in an Azure App Service web app Linux container
using the official Sonarqube image and backed by an Azure SQL Server.

## Compatible Versions of Sonarqube

- **Compatible**: Sonarqube v10.5 and above v8.9.
- **Not Compatible**: Sonarqube v8.2 and below.

Sonarqube 7.8 and above does require extra configurations in order for 
the embedded Elasticsearch to be reliable (as in production environment),
so in order to run it in an Azure App Service Web App we are setting
an explicit configuration `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE` as `true`.

Also, there was a breaking change in environment variables naming convention since 
[SonarQube 8.2](https://community.sonarsource.com/t/8-2-environment-varible-docs-are-inconsistent-confusing/21805/3) 
which makes impossible to run this template against versions below v8.2.

Furthermore, there is no offical documentation being mantained for SonarQube versions
below v8.9 which implies that there may be other breaking changes between v7.7 (last version of this template) and v8.9
so those were removed from the template to avoid any other unknown impediments.

`Tags: Microsoft.Web/serverfarms, Microsoft.Web/sites, config, Microsoft.Sql/servers, firewallrules, databases`
