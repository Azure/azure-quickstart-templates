---
description: This template provisions a function app on a Premium plan with production slot and an additional deployment slot.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-deployment-slot
languages:
- json
---
# Azure Function App with a Deployment Slot

This sample Azure Resource Manager template deploys an Azure Function App with production slot and an additional <a href="https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-slots">deployment slot</a>.

[![Deploy to Azure](/images/deploytoazure.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Ffunction-app-arm-templates%2Fmain%2Ffunction-app-deployment-slot%2Fazuredeploy.json)

### OS

This template has a parameter `functionPlanOS` to choose Windows or Linux OS. Windows is selected by default. If you choose Linux, then parameter `linuxFxVersion` will be parameter, so you can skip it for Windows.

### Elastic Premium Plan

The Azure Function app provisioned in this sample uses an [Azure Functions Elastic Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan#features). 

+ **Microsoft.Web/serverfarms**: The Azure Functions Premium plan (a.k.a. Elastic Premium plan)

### Azure Function App

The Function App uses the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) and [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) app settings to connect to a Storage Account.

+ **Microsoft.Web/sites**: The function app instance.

### Deployment Slot

Azure Functions [deployment slots](https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-slots) allow your function app to run different instances called "slots". Slots are different environments exposed via a publicly available endpoint. One app instance is always mapped to the production slot, and you can swap instances assigned to a slot on demand. 

Function apps running under the Apps Service plan may have multiple slots, while under the Consumption plan only one slot is allowed.

For Windows, do not need to set the [WEBSITE_CONTENTSHARE](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings#website_contentshare) setting in a deployment slot. This setting is generated for you when the app is created in the deployment slot.

+ **Microsoft.Web/sites/slots**: The deployment slot for the function app.

### Azure Storage account

The Storage account that the Function uses for operation and for file contents. 

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to provide [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

`Tags: Microsoft.Storage/storageAccounts, microsoft.insights/components, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.Web/sites/slots`
