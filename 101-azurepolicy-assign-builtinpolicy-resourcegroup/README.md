# Assign a built-in policy to an existing Resource Group

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-azurepolicy-assign-builtinpolicy-resourcegroup/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurepolicy-assign-buildinpolicy-resourcegroup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurepolicy-assign-buildinpolicy-resourcegroup%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template assigns a built-in policy to an existing resource group. You must be an owner of the subscription to apply a policy at this scope. Inputs to this template are following fields:

- policyDefinitionID
- policyAssignmentName

The following PowerShell script shows how to get the policy definition ID and the policy display name of a built-in policy called "Audit resource location matches resource group location". 

    PS C:\> $definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Audit resource location matches resource group location' }
            $policyDefinitionID = $definition.PolicyDefinitionId

