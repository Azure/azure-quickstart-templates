---
description: This template assigns a built-in policy to a resource group scope to audit virtual machine (VM) managed disks.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azurepolicy-builtin-vm-managed-disks
languages:
- bicep
- json
---
# Assign built-in policy to audit VM managed disks

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-builtin-vm-managed-disks/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fazurepolicy-builtin-vm-managed-disks%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fazurepolicy-builtin-vm-managed-disks%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fazurepolicy-builtin-vm-managed-disks%2Fazuredeploy.json)

This template assigns a built-in policy to an existing resource group that audits virtual machine managed disks. The following parameters are used in the template:

- `policyAssignmentName` creates the policy assignment named _audit-vm-managed-disks_.
- `policyDefinitionID` uses the ID of the built-in policy definition.
- `policyDisplayName` creates a display name that's visible in Azure portal, _Audit VM managed disks_.

The following commands display the `policyDefinitionID` parameter's value:

## Azure PowerShell

```
(Get-AzPolicyDefinition |
  Where-Object { $_.Properties.DisplayName -eq 'Audit VMs that do not use managed disks' }).ResourceId
```

## Azure CLI

```
az policy definition list \
  --query "[?displayName=='Audit VMs that do not use managed disks']".id \
  --output tsv
```

To learn more about how to deploy the template, [ARM template quickstart](https://learn.microsoft.com/azure/governance/policy/assign-policy-template).

`Tags: Microsoft.Authorization/policyAssignments`
