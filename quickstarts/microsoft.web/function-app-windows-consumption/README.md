---
description: This template provisions a function app on a Windows Consumption plan, which is a dynamic hosting plan. The app runs on demand and you're billed per execution, with no standing resource committment.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-windows-consumption
languages:
- json
---
# Azure Function App Hosted on Windows Consumption Plan

This sample Azure Resource Manager template deploys an Azure Function App on Windows Consumption plan and required resource including ZipDeploy extension to mount zip package for deployment.

[![Deploy to Azure](/images/deploytoazure.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Ffunction-app-arm-templates%2Fmain%2Ffunction-app-windows-consumption%2Fazuredeploy.json)

### OS

This template is for Azure Function app hosted on **Windows Consumption plan** only.

### Comsumption Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Consumption plan](https://docs.microsoft.com/en-us/azure/azure-functions/consumption-plan). 

+ **Microsoft.Web/serverfarms**: The Azure Functions Consumption plan (a.k.a. Dynamic plan)

### Azure Function App

The Function App uses the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) and [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) app settings to connect to a Storage Account.

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
