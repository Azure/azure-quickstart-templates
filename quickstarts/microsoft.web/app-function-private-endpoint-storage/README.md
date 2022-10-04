---
description: This template allows you to deploy an azure premium function with a storage account which is only reachable through a private endpoint
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: app-function-private-endpoint-storage
languages:
- json
- bicep
---
# Deploy an azure function with private endpoints 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/app-function-private-endpoint-storage/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-function-private-endpoint-storage%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fapp-function-private-endpoint-storage%2Fazuredeploy.json)

This template allows you to deploy an azure premium function with a storage account which is only reachable through a private endpoint. Azure private endpoints allow you to connect privately and securely to an Azure service. [Private endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview) require a DNS record for the resource, therefore an Azure DNS Zone is created to set the dns record accordingly 

`Tags: FunctionApp, Microsoft.Web/serverfarms, Microsoft.Network/virtualNetworks, Microsoft.Web/sites, Microsoft.Storage/storageAccounts`