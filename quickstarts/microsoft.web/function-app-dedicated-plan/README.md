---
description: This template provisions a function app on a dedicated hosting plan, meaning it will be run and billed just like any App Service site.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-dedicated-plan
languages:
- json
---
# Azure Function App Hosted on Dedicated Plan

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-dedicated-plan/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-dedicated-plan/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-dedicated-plan/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-dedicated-plan/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-dedicated-plan/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-dedicated-plan/CredScanResult.svg)

This sample Azure Resource Manager template deploys an Azure Function App hosted on Dedicated plan and required resource including ZipDeploy extension to mount zip package for deployment.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-dedicated-plan%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-dedicated-plan%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-dedicated-plan%2Fazuredeploy.json)


### OS

This template has a parameter `functionPlanOS` to choose Windows or Linux OS. Windows is selected by default. If you choose Linux, then parameter `linuxFxVersion` will be required, so you can skip it for Windows.

### Dedicated Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Dedicated plan](https://docs.microsoft.com/en-us/azure/azure-functions/dedicated-plan).

+ **Microsoft.Web/serverfarms**: The Azure Functions Dedicated plan (a.k.a. App Service plan)

### Azure Function App

The Function App uses the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) app setting to connect to a Storage Account.

+ **Microsoft.Web/sites**: The function app instance.

### ZipDeploy Extension

The Zip Deploy extension is added along with recommended app setting `WEBSITE_RUN_FROM_PACKAGE=1` to mount the zip package for deployment. This is the recommended path for deployment, except for [Linux Consumption Plan](/function-app-linux-consumption)

+ **Microsoft.Web/sites/extensions**: The ZipDeploy extension.

### Azure Storage account

The Storage account that the Function uses for operation and for file contents.

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to provide [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

`Tags: Microsoft.Storage/storageAccounts, microsoft.insights/components, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/extensions`
