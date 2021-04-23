# Assign a built-in policy to an existing resource group

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-assign-builtinpolicy-resourcegroup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-assign-builtinpolicy-resourcegroup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-assign-builtinpolicy-resourcegroup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-assign-builtinpolicy-resourcegroup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-assign-builtinpolicy-resourcegroup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.authorization/azurepolicy-assign-builtinpolicy-resourcegroup/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fazurepolicy-assign-builtinpolicy-resourcegroup%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fazurepolicy-assign-builtinpolicy-resourcegroup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.authorization%2Fazurepolicy-assign-builtinpolicy-resourcegroup%2Fazuredeploy.json)

This template assigns a built-in policy to an existing resource group. You must be an owner of the scope (subscription, resourceGroup) to apply a policy. Inputs to this template are the following fields:

- `policyDefinitionID`
- `policyAssignmentName`

The following PowerShell script shows how to get the policy definition ID and the policy display name of a built-in policy called _Audit resource location matches resource group location_.

```powershell
$policyDefinitionId = $(Get-AzPolicyDefinition  | Where-Object { $_.Properties.DisplayName -eq 'Audit resource location matches resource group location' }).PolicyDefinitionId
```

To learn more about how to deploy the template, see the [quickstart](https://docs.microsoft.com/azure/governance/policy/assign-policy-template) article.
