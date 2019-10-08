# "RBAC - Grant Azure AD authorization access on Azure Maps for multiple principals

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-rbac-multipleprincipals-maps/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-rbac-multipleprincipals-maps/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-rbac-managedidentity-maps/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-rbac-managedidentity-maps/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-rbac-multipleprincipals-maps/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-rbac-multipleprincipals-maps/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-rbac-multipleprincipals-maps%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-rbac-multipleprincipals-maps%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template assigns Azure Maps Data Reader access for multiple users, groups, or applications to an Azure Maps account in a resource group.

## Use following powershell command to get Principal ID

This id is associated with a user using their email or display name. **Please note** principal id maps to the object id inside the directory and can point to a user, service principal, or security group.

ObjectId is referred to as Principal ID

    PS C:\> $account = Connect-AzureRmAccount -SubscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    PS C:\> Connect-AzureAD -TenantId $account.Context.Tenant.Id
    PS C:\> Get-AzureADUser -SearchString "Display name or mail"

    ObjectId                             DisplayName                   UserPrincipalName
    -----------                          -----------                   -----------------
    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx <display name>                <email>

### Using groups can reduce role assignments and deployments

Using a security group is ideal if you have a group of principals you wish to maintain access without consistant deployments which change access.

## Parameter #5: 'GUIDs' represent randomly generated GUIDs

These values should be unique per element as they represent the id of the role assignment. They can be generate any way you prefer.

## For Automation on role assignments you must assign 'User Access Administrator'

For automation scenarios without a user's principal, the built in role you must assign your automation is "User Access Adminstrator". This role with grant access to add and remove role assignments. The other option can be to create a [custom role definition](https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles) with the permissions `Microsoft.Authorization/roleAssignments/write` and `Microsoft.Authorization/roleAssignments/delete`.
