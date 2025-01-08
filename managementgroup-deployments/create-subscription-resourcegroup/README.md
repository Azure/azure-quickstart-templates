---
description: This template is a management group template that will create a subscription, a resourceGroup and a storageAccount in the same template.  It can be used for an Enterprise Agreement billing mode only.  The official documentation shows modifications needed for other types of accounts.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-subscription-resourcegroup
languages:
- json
- bicep
---
# Create a subscription, resourceGroup and storageAccount

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/managementgroup-deployments/create-subscription-resourcegroup/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmanagementgroup-deployments%2Fcreate-subscription-resourcegroup%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmanagementgroup-deployments%2Fcreate-subscription-resourcegroup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmanagementgroup-deployments%2Fcreate-subscription-resourcegroup%2Fazuredeploy.json)

This template is a management group scope template that creates a subscription, resourceGroup and storageAccount under an EA account.  See the [documentation](https://docs.microsoft.com/azure/cost-management-billing/manage/programmatically-create-subscription) for how to create subscriptions programmatically under other types of billing accounts.

`Tags: Microsoft.Resources/deployments, Microsoft.Subscription/aliases, Microsoft.Resources/resourceGroups, Microsoft.Storage/storageAccounts`
