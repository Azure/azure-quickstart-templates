# Azure User Managed Identity 

This Bicep template deploys a user assigned managed identity and associates RBAC role to the MSI.

## Deployment steps ##

* [Install the Bicep CLI](https://github.com/Azure/bicep/blob/main/docs/installing.md) by following the instruction.
* Build the `main.bicep` file by running the Bicep CLI command:
  
```bash
bicep build ./main.bicep

New-AzResourceGroupDeployment -TemplateFile ./main.json -ResourceGroupName <resource group name> -Verbose
```

TODO: Clean up README
