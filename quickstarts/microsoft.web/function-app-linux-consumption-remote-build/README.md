---
description: This template provisions a function app on a Linux Consumption plan, which is a dynamic hosting plan. The app runs on demand and you're billed per execution, with no standing resource committment.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-linux-consumption-remote-build
languages:
- json
---
# Azure Function App Hosted on Linux Consumption Plan

This sample Azure Resource Manager template deploys an Azure Function App on Linux Consumption plan and required resource including the app setting to deploy using zip package when **remote build** is needed (for example: to get Linux specific packages in python, node.js).

[![Deploy to Azure](/images/deploytoazure.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Ffunction-app-arm-templates%2Fmain%2Ffunction-app-linux-consumption-remote-build%2Fazuredeploy.json)

### OS

This template is for Azure Function app hosted on **Linux Consumption plan** only.

### Comsumption Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Consumption plan](https://docs.microsoft.com/en-us/azure/azure-functions/consumption-plan). 

+ **Microsoft.Web/serverfarms**: The Azure Functions Consumption plan (a.k.a. Dynamic plan)

### Azure Function App

The Function App uses the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) app settings to connect to a Storage Account.

+ **Microsoft.Web/sites**: The function app instance.

### Deploy using .ZIP package with Remote Build

To enable the remote build processes with ZipDeploy extension, update the following to your application settings:
+ `WEBSITE_RUN_FROM_PACKAGE=0` or Remove WEBSITE_RUN_FROM_PACKAGE app setting
+ `SCM_DO_BUILD_DURING_DEPLOYMENT=true`

NOTE: ZipDeploy extension with the appSetting `SCM_DO_BUILD_DURING_DEPLOYMENT=true` is honored only if `WEBSITE_RUN_FROM_PACKAGE=0`or Remove WEBSITE_RUN_FROM_PACKAGE app setting.

### Azure Storage account

The Storage account that the Function uses for operation and for file contents. 

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to provide [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

`Tags: Microsoft.Storage/storageAccounts, microsoft.insights/components, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/extensions`
