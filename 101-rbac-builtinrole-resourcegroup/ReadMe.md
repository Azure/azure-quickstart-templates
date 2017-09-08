<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-rbac-builtinrole-resourcegroup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-rbac-builtinrole-resourcegroup%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template assigns Owner, Reader or Contributor access to an existing resource group. Inputs to this template are following fields:

- Principal ID
- Role Definition Type


**Use following powershell command to get Principal ID associated with a user using their email id. Please note, principal id maps to the id inside the directory and can point to a user, service principal, or security group. The ObjectId is the principal ID.

    PS C:\> Get-AzureADUser -mail <email id>
    
    DisplayName                    Type                           ObjectId
    -----------                    ----                           --------
    <NAME>                                                        xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx


**Use following powershell command to learn about RoleDefinitions. Please note, the template already uses appropriate roleDefinition Id. The applicable RoleDefinition names are avialable in the parameter dropdown. 

    PS C:\> Get-AzureRoleDefinition | fl

    Name       : Contributor
    Id         : /subscriptions/ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c
    Actions    : {*}
    NotActions : {Microsoft.Authorization/*/Write, Microsoft.Authorization/*/Delete} 

