# Create a user-assigned managed identity and role assignments

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.ManagedIdentity%2Fuser-assigned-identity-role-assignment%2F1.0%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.ManagedIdentity%2Fuser-assigned-identity-role-assignment%2F1.0%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules%2FMicrosoft.ManagedIdentity%2Fuser-assigned-identity-role-assignment%2F1.0%2Fazuredeploy.json)   

This module creates a user-assigned managed identity. It also optionally assigns the managed identity to one or more roles at the resource group scope.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| managedIdentityName | string | Yes | The name of the managed identity resource. |
| roleDefinitionIds | string | No | The IDs of the role definitions to assign to the managed identity. Each role assignment is created at the resource group scope. Role definition IDs are GUIDs. To find the GUID for built-in Azure role definitions, see https://docs.microsoft.com/azure/role-based-access-control/built-in-roles. You can also use IDs of custom role definitions. |
| roleAssignmentDescription | string | No | An optional description to apply to each role assignment, such as the reason this managed identity needs to be granted the role. |
| location | string | No | The Azure location where the managed identity should be created. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| managedIdentityResourceId | string | The resource ID of the user-assigned managed identity. |
| managedIdentityClientId | string | The ID of the Azure AD application associated with the managed identity. |
| managedIdentityPrincipalId | string | The ID of the Azure AD service principal associated with the managed identity. |

```apiVersion: 2018-11-30```
