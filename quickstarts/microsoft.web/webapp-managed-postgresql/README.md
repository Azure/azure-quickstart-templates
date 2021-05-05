# Build a Web App with PostgreSQL

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-managed-postgresql/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-managed-postgresql/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-managed-postgresql/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-managed-postgresql/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-managed-postgresql/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webapp-managed-postgresql/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)]("https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-managed-postgresql%2Fazuredeploy.json")
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]("https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-managed-postgresql%2Fazuredeploy.json")
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)]("http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebapp-managed-postgresql%2Fazuredeploy.json")

This template provides a easy way to deploy web app on Azure Web Apps on Windows with [Azure database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/overview#azure-database-for-postgresql---single-server)

This template deploys a web app with a managed PostgreSQL managed database of [different pricing tiers: Basic, General Purpose, and Memory Optimized](https://docs.microsoft.com/en-us/azure/postgresql/concepts-pricing-tiers). The web app with PostgreSQL is an app service that allows you to deploy and managed PostgreSQL data and a website. This will deploy a free tier Linux App Service Plan where you will host your app service.

If you are new to Azure App Service, see:

- [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/web/)
- [Template reference](https://docs.microsoft.com/es-es/azure/templates/microsoft.web/allversions)
- [Quickstart templates](https://azure.microsoft.com/es-es/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular&term=web+apps)
- [PostgreSQL Web App Tutorial](https://docs.microsoft.com/azure/app-service/containers/tutorial-python-postgresql-app)
- [Microsoft Learn PostgreSQL modules](https://docs.microsoft.com/learn/browse/?term=Postgres)

If you are new to template deployment, see:
[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

## Prerequisites

If you have already a Linux App Service Plan, you will have to deploy the new web app into the same resource group that the other web app is. That's because Student accounts has a limit of only 1 free tier Linux app service plan.

`Tags: Azure4Student, appServices , PostgreSQL, linux, Beginner`
