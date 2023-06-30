---
description: his template provisions an Azure Function app on a Linux Consumption plan, along with an Event Hub, Azure Storage, and Application Insights.  The function app is able to use managed identity to connect to the Event Hub and Storage account
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-event-hub-managed-identity
languages:
- bicep
- json
---
# Azure Function App with Event Hub and Managed Identity

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-event-hub-managed-identity/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-event-hub-managed-identity%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-event-hub-managed-identity%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-event-hub-managed-identity%2Fazuredeploy.json)

## Overview and deployed resources

This sample Azure Resource Manager template deploys an Azure Function App on Linux Consumption plan, Event Hub, Azure Storage account, and Application Insights.  Authentication between the function app and Event Hub and Storage is handled via the function's managed identity.  Application deployment can be do using a zip package.

### Azure Function App

The Function App uses the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) app settings to connect to a Storage Account.

The Azure Function app provisioned in this sample uses an [Azure Functions Consumption plan](https://docs.microsoft.com/azure/azure-functions/consumption-plan).

+ **Microsoft.Web/sites**: The function app instance.
+ **Microsoft.Web/serverfarms**: The Azure Functions Consumption plan (a.k.a. Dynamic plan)

#### OS

This template is for Azure Function app hosted on **Linux Consumption plan** only.

#### Deploy using .ZIP package

ZipDeploy extension with the appSetting `WEBSITE_RUN_FROM_PACKAGE=1` is not supported only for Linux Consumption plan. For Linux Consumption plan:

1. Do not use ZipDeploy extension.
2. Set appSetting `WEBSITE_RUN_FROM_PACKAGE=URL` for deployment using the .zip package url.

#### Identity-Based Connection

The function app uses an [identity-based connection](https://learn.microsoft.com/azure/azure-functions/functions-reference?tabs=blob#configure-an-identity-based-connection) instead of secrets for connecting to the Azure Storage account and Event Hub.

### Event Hub

An Event Hub that can be used by the function.  An identity-based connection is for the function to connect to the Event Hub.

+ **Microsoft.EventHub/namespaces**: The Event Hub namespace and related event hub.

### Azure Storage account

The Storage account that the Function uses for operation and for file contents.

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to provide [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

## Deployment Steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: Microsoft.Storage/storageAccounts, microsoft.insights/components, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.EventHub/namespaces`
