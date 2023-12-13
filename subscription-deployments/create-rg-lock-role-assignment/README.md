---
description: This template is a subscription level template that will create a resourceGroup, apply a lock the the resourceGroup and assign contributor permssions to the supplied principalId.  Currently, this template cannot be deployed via the Azure Portal.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: create-rg-lock-role-assignment
languages:
- json
- bicep
---
# Create a resourceGroup, apply a lock and RBAC

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/subscription-deployments/create-rg-lock-role-assignment/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fcreate-rg-lock-role-assignment%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fcreate-rg-lock-role-assignment%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsubscription-deployments%2Fcreate-rg-lock-role-assignment%2Fazuredeploy.json)

This template is a subscription level template that creates a resource group, applies a DoNotDelete lock to that group, and assigns the contributor role to a principal specified in a template parameters.

*NOTE: Role Assigments use a GUID for the name, this must be unique for every role assignment on the group.  The roleAssignmentName parameter is used to seed the guid() function with this value, change it for each deployment.  You can supply a guid or any string, as long as it has not been used before when assigning the role to the resourceGroup.*

`Tags: Microsoft.Resources/resourceGroups, Microsoft.Resources/deployments, Microsoft.Authorization/locks, Microsoft.Authorization/roleAssignments`
