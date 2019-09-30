# RBAC - Existing VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-virtualmachine/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-virtualmachine/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-virtualmachine/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-virtualmachine/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-virtualmachine/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-rbac-builtinrole-virtualmachine/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-rbac-builtinrole-virtualmachine%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-rbac-builtinrole-virtualmachine%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template assigns Owner, Reader, Contributor, Virtual Machine Contributor access to an existing VM in a resource group. Inputs to this template are following fields:

Principal ID
Role Definition ID
Virtual Machine Name
GUID

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

