# Azure Functions Premium plan with Virtual Network Integration

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/function-premium-vnet-integration/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-premium-vnet-integration%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Ffunction-premium-vnet-integration%2Fazuredeploy.json)

This template deploys an Azure Function Premium plan with [regional virtual network integration](https://docs.microsoft.com/azure/azure-functions/functions-networking-options#regional-virtual-network-integration).

## Overview and deployed resources

An Azure Function Premium plan with virtual network integration enabled allows the Azure Function to utilizes resources within the virtual network.

The following resources are deployed as part of the solution:

### Virtual Network

The virtual network into which the Azure Function Premium plan shall be integrated.

+ **Microsoft.Network/virtualNetworks**: The virtual network for which to integrate, and one subnet to which the function app plan is delegated.

### Azure Function Premium Plan

The [Azure Functions Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan) which enables virtual network integration.

+ **Microsoft.Web/serverfarms**: The Azure Functions Premium plan (a.k.a. Elastic Premium plan)

### Function App

The function app to be deployed as part of the Azure Functions Premium plan.

+ **Microsoft.Web/sites**: The function app instance.

### Application Insights

Application Insights is used to provide [monitoring for the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

+ **Microsoft.Insights/components**: The Application Insights instance used by the Azure Function for monitoring.

### Azure Storage

The Azure Storage account used by the Azure Function.

+ **Microsoft.Storage/storageAccounts**: [Azure Functions requires a storage account](https://docs.microsoft.com/azure/azure-functions/storage-considerations) for the function app instance.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.
