---
description: This template provisions a function app on a Linux Consumption plan, which is a dynamic hosting plan. The app runs on demand and you're billed per execution, with no standing resource committment.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-linux-consumption
languages:
- bicep
- json
---
# Azure Function App Hosted on Linux Consumption Plan

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-linux-consumption/BicepVersion.svg)

This sample Azure Resource Manager template deploys an Azure Function App on Linux Consumption plan and required resource including the app setting to deploy using zip package.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-linux-consumption%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-linux-consumption%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-linux-consumption%2Fazuredeploy.json)

### OS

This template is for Azure Function app hosted on **Linux Consumption plan** only.

### Comsumption Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Consumption plan](https://docs.microsoft.com/en-us/azure/azure-functions/consumption-plan).

+ **Microsoft.Web/serverfarms**: The Azure Functions Consumption plan (a.k.a. Dynamic plan)

### Azure Function App

The Function App uses the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) app settings to connect to a Storage Account.

+ **Microsoft.Web/sites**: The function app instance.

### Deploy using .ZIP package

ZipDeploy extension with the appSetting `WEBSITE_RUN_FROM_PACKAGE=1` is not supported only for Linux Consumption plan. For Linux Consumption plan:
1. Do not use ZipDeploy extension.
2. Set appSetting `WEBSITE_RUN_FROM_PACKAGE=URL` for deployment using the .zip package url.

### Azure Storage account

The Storage account that the Function uses for operation and for file contents.

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to provide [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

`Tags: Microsoft.Storage/storageAccounts, microsoft.insights/components, Microsoft.Web/serverfarms, Microsoft.Web/sites`
