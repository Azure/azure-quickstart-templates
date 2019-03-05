# Assign a built-in policy to an existing Resource Group

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurepolicy-assign-buildinpolicy-resourcegroup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-azurepolicy-assign-buildinpolicy-resourcegroup%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template assigns a built-in policy to an existing resource group. You must be an owner of the subscription to apply a policy at this scope. Inputs to this template are following fields:

- policyDefinitionID
- policyAssignmentName

The following PowerShell script shows how to get the policy definition ID and the policy display name of a built-in policy called "Audit resource location matches resource group location". 

    PS C:\> $definition = Get-AzPolicyDefinition | Where-Object { $_.Properties.DisplayName -eq 'Audit resource location matches resource group location' }
            $policyDefinitionID = $definition.PolicyDefinitionId
