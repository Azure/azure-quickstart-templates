---
description: This template assigns a built-in policy to a resource group scope to audit virtual machine (VM) managed disks.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: azurepolicy-builtin-vm-managed-disks
languages:
- json
---
# Assign built-in policy to audit VM managed disks

This template assigns a built-in policy to an existing resource group that audits virtual machine managed disks. The following parameters are used in the template:

- `policyAssignmentName` creates the policy assignment named _audit-vm-managed-disks_.
- `policyDefinitionID` uses the ID of the built-in policy definition.
- `policyDisplayName` creates a display name that's visible in Azure portal.

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
