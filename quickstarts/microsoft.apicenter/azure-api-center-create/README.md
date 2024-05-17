---
description: This template creates an API center and registers an API in the API center.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azure-api-center-create
languages:
- bicep
- json
---
# Create an Azure API Center instance using a template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apicenter/azure-api-center-create/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apicenter%2Fazure-api-center-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apicenter%2Fazure-api-center-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apicenter%2Fazure-api-center-create%2Fazuredeploy.json)

This template deploys an API center and registers a sample API in the API center. For deployment, use a resource group located in one of the [supported regions](https://learn.microsoft.com/azure/api-center/overview#available-regions) for Azure API Center.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| location | string | Yes | Specifies the location for the API center. |
| apiCenterName | string | Yes | Specifies the name of the API center. |
| apiName | string | No | Specifies the name of an API to register in the API center. |
| apiType | string | No | Specifies the type of API to register in the API center. Example: *REST*. |


`Tags: Microsoft.ApiCenter/service`
