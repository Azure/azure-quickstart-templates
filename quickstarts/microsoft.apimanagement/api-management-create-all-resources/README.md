---
description: This template demonstrates how to create an API Management instance and configure subresources
page_type: sample
products:
- azure
- azure-resource-manager
- azure-api-management
urlFragment: api-management-create-all-resources
languages:
- json
---
# Create an API Management instance and all subresources using template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.apimanagement/api-management-create-all-resources/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-all-resources%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-all-resources%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.apimanagement%2Fapi-management-create-all-resources%2Fazuredeploy.json)

This template provides an example of how to create API Management service and configure subresources including APIs, policies, products, subscriptions, and so on. NOTE: this is an example and most of the resources need to be modified to your needs before using this template.

`Tags: Microsoft.ApiManagement/service, policies, apis, operations, products, users, properties, subscriptions, certificates, groups, openidConnectProviders, loggers, identityProviders`
