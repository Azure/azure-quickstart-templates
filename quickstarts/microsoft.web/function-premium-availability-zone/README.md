---
description: This template allows you to deploy an Azure Function Premium plan with availability zones support, including an availability zones enabled storage account.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-premium-availability-zone
languages:
- json
- bicep
---
# Deploy an AZ enabled Azure Function Premium plan

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-availability-zone/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-premium-availability-zone%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-premium-availability-zone%2Fazuredeploy.json)

This template deploys an Azure Function Premium plan with [availability zones support](https://docs.microsoft.com/azure/azure-functions/azure-functions-az-redundancy).

## Overview and deployed resources

An Azure Function Premium plan with availability zones support, to help you achieve resiliency and reliability for your business-critical workloads. The template also deploys the associated storage account with availability zones enabled.

The following resources are deployed as part of the solution:

### Azure Function Premium Plan

The [Azure Functions Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan) with availability zones support.

+ **Microsoft.Web/serverfarms**: The Azure Functions Premium plan (a.k.a. Elastic Premium plan)

### Function App

The function app to be deployed as part of the Azure Functions Premium plan.

+ **Microsoft.Web/sites**: The function app instance.

### Application Insights

Application Insights is used to provide [monitoring for the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

### Log Analytics Workspace

The Log Analytics workspace used by Application Insights is used to provide [a workspace for the Application Insights telemetry](https://docs.microsoft.com/azure/azure-monitor/app/create-workspace-resource).

+ **Microsoft.OperationalInsights/workspaces**: The Log Analytics workspace instance used by Application Insights for telemetry.

### Azure Storage

The Azure Storage account used by the Azure Function with availability zones enabled.

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Insights/components, Microsoft.OperationalInsights/workspaces, Microsoft.Web/serverfarms, Microsoft.Web/sites`
