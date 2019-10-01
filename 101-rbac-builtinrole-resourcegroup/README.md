# Assign an RBAC role to a Resource Group

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-resourcegroup/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-resourcegroup/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-resourcegroup/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-resourcegroup/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-resourcegroup/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-resourcegroup/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-rbac-builtinrole-resourcegroup%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-rbac-builtinrole-resourcegroup%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template assigns Owner, Reader or Contributor access to an existing resource group. Inputs to this template are following fields:

- Principal ID
- Role Definition ID

**Use the following Azure PowerShell cmdlet to get Principal ID associated with a user using their email id. Please note, principal id maps to the id inside the directory and can point to a user, service principal, or security group. The ObjectId is the principal ID.

    PS C:\> Get-AzADUser -mail <email id>
    
    DisplayName                    Type                           ObjectId
    -----------                    ----                           --------
    <NAME>                                                        xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

**Use the following Azure PowerShell cmdlet to learn about role definitions.

    PS C:\> Get-AzRoleDefinition -Name "reader"

    Name             : Reader
    Id               : acdd72a7-3385-48ef-bd42-f606fba81ae7
    IsCustom         : False
    Description      : Lets you view everything, but not make any changes.
    Actions          : {*/read}
    NotActions       : {}
    DataActions      : {}
    NotDataActions   : {}
    AssignableScopes : {/}

   You can use the same cmdlet to get the role definition ID for owner and contributor.

    "Owner": "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    "Contributor": "b24988ac-6180-42a0-ab88-20f7382dd24c"
    "Reader": "acdd72a7-3385-48ef-bd42-f606fba81ae7"

If you are new to RBAC for Azure resources, see:

- [RBAC documentation](https://docs.microsoft.com/azure/role-based-access-control/)
- [RBAC template reference](https://docs.microsoft.com/azure/templates/microsoft.authorization/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Authorization&pageNumber=1&sort=Popular)

If you are new to the template development, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/)
- [Create resource groups and resources at the subscription level](https://docs.microsoft.com/azure/azure-resource-manager/deploy-to-subscription#create-roles)

Tags: RBAC for Azure resources, role-based access control, Resource Manager, Resource Manager templates, ARM templates

