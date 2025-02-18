---
description: This template creates a serverless function app in the Flex Consumption plan, which is the preferred dynamic hosting plan. When your app runs in the Flex Consumption plan, instances of the Functions host are dynamically added and removed based on the configured per instance concurrency and the number of incoming events. This app securely connects to other Azure services by using Microsoft Entra ID with user-assigned managed identities. 
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: function-app-flex-managed-identities
languages:
- bicep
- json
---

# Function app hosted by Azure Functions in a Flex Consumption plan

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-app-flex-managed-identities/BicepVersion.svg)

This sample Bicep file or Azure Resource Manager (ARM) template create a serverless function app in the Flex Consumption plan, which is the preferred dynamic hosting plan. When your app runs in the Flex Consumption plan, instances of the Functions host are dynamically added and removed based on the configured per instance concurrency and the number of incoming events. This app securely connects to other Azure services by using Microsoft Entra ID with user-assigned managed identities.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-flex-managed-identities%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-flex-managed-identities%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-app-flex-managed-identities%2Fazuredeploy.json)

The deployment is composed of these primary Azure resources:

| Identifier | Resource | Description |
| ----- | ----- | ----- |
| **`Microsoft.Web/serverfarms`** | [Flex Consumption plan](https://docs.microsoft.com/azure/azure-functions/flex-consumption-plan) | A specific type of App Service plan that enables your functions to scale dynamically (even to zero instances and under high loads), connect to virtual networks, use managed identity connections, and reduce cold-starts. The Flex Consumption plan currently runs only on Linux. |
| **`Microsoft.Web/sites`** | Function app instance | Provides the Functions hosting and runtime support for your functions code project. By default, this template hosts a .NET (C#) isolated process app. You can use the `functionAppRuntime` and `functionAppRuntimeVersion` parameters to choose a different language for your app. |
| **`Microsoft.Storage/storageAccounts`** | [Default Azure Storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) | Each function app deployment requires a storage account that's used by the Functions runtime. This template disables key-based access to storage account resources. You can use the `storageAccountAllowSharedKeyAccess` variable to toggle shared key access to access storage account resources during testing and development. To enhance security, you should disable shared key access in production. The function app connects to storage with user-assigned managed identities that are granted role-based access to a limited number of resources. The connection is defined by the `AzureWebJobsStorage_*` setting structure. |
| **`Microsoft.Insights/components`** | [Application Insights instance](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)| Application Insights helps you [monitor your function app performance and behaviors](https://docs.microsoft.com/azure/azure-functions/functions-monitoring). It requires an associated Log Analytics (`Microsoft.OperationalInsights/workspaces`) resource.  |
| **`Microsoft.ManagedIdentity/userAssignedIdentities`** | User-assiged managed identity | Connections to both Azure Storage and Application Insights are secured by using Microsoft Entra ID with a user-assigned managed identity. The identity is assigned the required roles in the remote services by using `Microsoft.Authorization/roleAssignments` resource definitions. |

`Tags: Microsoft.Storage/storageAccounts, microsoft.insights/components, Microsoft.Web/serverfarms, Microsoft.Web/sites, Microsoft.ManagedIdentity/userAssignedIdentities,Microsoft.OperationalInsights/workspaces`
