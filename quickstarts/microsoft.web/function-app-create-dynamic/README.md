---
description: This template provisions a function app on a Consumption plan, which is a dynamic hosting plan. The app runs on demand and you're billed per execution, with no standing resource committment. There are other templates available for provisioning on a dedicated hosting plan.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-create-dynamic
languages:
- bicep
- json
---
# Provision a function app on a Consumption plan

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/CredScanResult.svg)

**Important:** If you're using an App Service Plan, use [101-function-app-create-dedicated](https://github.com/Azure/azure-quickstart-templates/tree/master/101-function-app-create-dedicated).

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-create-dynamic/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-create-dynamic%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-create-dynamic%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-create-dynamic%2Fazuredeploy.json)

Azure Functions is a solution for running small pieces of code, or functions, in the cloud. You can write just the code you need for the problem at hand, without worrying about a whole application or the infrastructure to run it.

For more information about Azure Functions, see the following articles:

- [Azure Functions Overview](https://azure.microsoft.com/documentation/articles/functions-overview/)
- [Quickstart: Create and deploy Azure Functions resources from an ARM template](https://docs.microsoft.com/azure/azure-functions/functions-create-first-function-resource-manager)

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Web/serverfarms, Microsoft.Web/sites, SystemAssigned, Microsoft.Insights/components`
