---
description: This template creates a key vault, managed identity, and role assignment.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: key-vault-managed-identity-role-assignment
languages:
- json
- bicep
---
# Create key vault, managed identity, and role assignment

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.keyvault/key-vault-managed-identity-role-assignment/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-managed-identity-role-assignment%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-managed-identity-role-assignment%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.keyvault%2Fkey-vault-managed-identity-role-assignment%2Fazuredeploy.json)

This template creates a key vault and managed identity, and a role assignment for the managed identity to access the key vault.

For more information about using Bicep to deploy key vaults, see [Manage secrets by using Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/scenarios-secrets#use-key-vault), and for information about using Bicep to deploy role assignments, see [Create Azure RBAC resources by using Bicep](https://docs.microsoft.com/azure/azure-resource-manager/bicep/scenarios-rbac).

## Deletion behavior

When a managed identity is deleted, any role assignments for that managed identity are not automatically deleted. If you try to deploy a new role assignment with the same role assignment ID, the deployment fails because the resource already exists and the `principalId` can't be modified.

To ensure that each deployment has a unique role assignment ID, you can use the `guid()` function with a seed value that is based in part on the managed identity's principal ID. However, because Azure Resource Manager requires each resource's name to be available at the beginning of the deployment, you can't use this approach in the same Bicep file that defines the managed identity. This sample uses a Bicep module to work around this issue.

`Tags: Microsoft.KeyVault/vaults, Microsoft.ManagedIdentity/userAssignedIdentities, Microsoft.Resources/deployments, Microsoft.Authorization/roleAssignments`