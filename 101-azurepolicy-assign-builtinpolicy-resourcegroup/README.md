# Assign a built-in policy to an existing Resource Group

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurepolicy-assign-buildinpolicy-resourcegroup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurepolicy-assign-buildinpolicy-resourcegroup%2Fazuredeploy.json)

This template assigns a built-in policy to an existing resource group. You must be an owner of the subscription to apply a policy at this scope. Inputs to this template are following fields:

- policyDefinitionID
- policyAssignmentName

The following PowerShell script shows how to get the policy definition ID and the policy display name of a built-in policy called "Audit resource location matches resource group location". 

```powershell
$definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Audit resource location matches resource group location' }
$policyDefinitionID = $definition.PolicyDefinitionId
```


