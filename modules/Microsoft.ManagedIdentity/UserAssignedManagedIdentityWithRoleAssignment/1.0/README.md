# Create a user-assigned managed identity and a role assignment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/modules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0%2Fazuredeploy.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmodules/Microsoft.ManagedIdentity/UserAssignedManagedIdentityWithRoleAssignment/1.0%2Fazuredeploy.json)

This module creates a user-assigned managed identity. It also assigns the managed identity to a specified role at the resource group scope.

## Parameters

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| managedIdentityName | string | Yes | The name of the managed identity resource. |
| roleAssignmentName | string | No | A globally unique identifier (GUID) to identify the role assignment. The name of the role assignment must be unique within the resource group. |
| roleDefinitionResourceId | string | Yes | The fully qualified Azure resource ID of the role definition to assign. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles for all built-in role definitions. For example, use `subscriptionResourceId(\'b24988ac-6180-42a0-ab88-20f7382dd24c\'` for the Contributor role. You can also use a custom role definition\'s resource ID. |
| roleAssignmentDescription | string | No | An optional description of the role assignment, such as the reason this managed identity needs to be granted the role. |
| location | string | No | The Azure location where the managed identity should be created. |

## Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| managedIdentityClientId | string | The ID of the Azure AD application associated with the managed identity. |
| managedIdentityPrincipalId | string | The ID of the Azure AD service principal associated with the managed identity. |
| managedIdentityTenantId | string | The ID of the tenant which the managed identity belongs to. |
| roleAssignmentName | string | The name of the role assignment. |

```apiVersion: 2018-11-30```
