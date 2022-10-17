---
description: This sample uses a deployment script to create objects in Azure Active Directory.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: deployment-script-azcli-graph-azure-ad
languages:
- json
- bicep
---
# Use a deployment script to create Azure AD objects

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/deployment-script-azcli-graph-azure-ad/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-graph-azure-ad%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-graph-azure-ad%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Fdeployment-script-azcli-graph-azure-ad%2Fazuredeploy.json)   

This example shows how to use a deployment script to interact with Microsoft Graph. The deployment script creates an Azure AD application and service principal, but you could use a similar approach to create other objects in Azure Active Directory.

As of October 2022, you can't use Bicep or ARM templates to grant Microsoft Graph permissions to a user-assigned managed identity. Before the deployment runs, you need to create a user-assigned managed identity, and grant it the appropriate permisions to the Graph API.

## Create a user-assigned managed identity

PowerShell with Azure cmdlets:

```powershell
$managedIdentityName = 'MyIdentity'
$resourceGroupName = 'MyResourceGroup'
$location = 'westus'

$userAssignedIdentity = New-AzUserAssignedIdentity `
  -Name $managedIdentityName `
  -ResourceGroupName $resourceGroupName `
  -Location $location
$managedIdentityObjectId = $userAssignedIdentity.PrincipalId
```

Azure CLI with Bash:

```bash
managedIdentityName='MyIdentity'
resourceGroupName='MyResourceGroup'
location='westus'

userAssignedIdentity=$(az identity create \
  --name $managedIdentityName \
  --resource-group $resourceGroupName \
  --location $location)
managedIdentityObjectId=$(jq -r '.principalId' <<< "$userAssignedIdentity")
```

## Grant permission to the Graph API

Next, you grant the user-assigned identity permission to create applications in Azure Active Directory.

PowerShell with Azure AD cmdlets:

```powershell
$tenantID = '<Your Azure AD tenant ID>'
Connect-AzureAD -TenantId $tenantID

# Get the app role for the Graph API.
$graphAppId = '00000003-0000-0000-c000-000000000000' # This is a well-known Microsoft Graph application ID.
$graphApiAppRoleName = 'Application.ReadWrite.All'
$graphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$graphAppId'"
$graphApiAppRole = $graphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $graphApiAppRoleName -and $_.AllowedMemberTypes -contains "Application"}

# Assign the role to the managed identity.
New-AzureADServiceAppRoleAssignment `
  -ObjectId $managedIdentityObjectId `
  -PrincipalId $managedIdentityObjectId `
  -ResourceId $graphServicePrincipal.ObjectId `
  -Id $graphApiAppRole.Id
```

Azure CLI with Bash:

```bash
tenantId='<Your Azure AD tenant ID>'

graphAppId='00000003-0000-0000-c000-000000000000' # This is a well-known Microsoft Graph application ID.
graphApiAppRoleName='Application.ReadWrite.All'
graphApiApplication=$(az ad sp list --filter "appId eq '$graphAppId'" --query "{ appRoleId: [0] .appRoles [?value=='$graphApiAppRoleName'].id | [0], objectId:[0] .id }" -o json)

# Get the app role for the Graph API.
graphServicePrincipalObjectId=$(jq -r '.objectId' <<< "$graphApiApplication")
graphApiAppRoleId=$(jq -r '.appRoleId' <<< "$graphApiApplication")

# Assign the role to the managed identity.
requestBody=$(jq -n \
                  --arg id "$graphApiAppRoleId" \
                  --arg principalId "$managedIdentityObjectId" \
                  --arg resourceId "$graphServicePrincipalObjectId" \
                  '{id: $id, principalId: $principalId, resourceId: $resourceId}' )
az rest -m post -u "https://graph.windows.net/$tenantId/servicePrincipals/$managedIdentityObjectId/appRoleAssignments?api-version=1.6" -b "$requestBody"
```

PowerShell with Microsoft Graph cmdlets:

```powershell
$tenantID = '<Your Azure AD tenant ID>'

Connect-MgGraph -TenantId $tenantID

# Get the app role for the Graph API.
$graphAppId = '00000003-0000-0000-c000-000000000000' # This is a well-known Microsoft Graph application ID.
$graphApiAppRoleName = 'Application.ReadWrite.All'
$graphServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$graphAppId'"
$graphApiAppRole = $graphServicePrincipal.AppRoles | Where-Object {$_.Value -eq $graphApiAppRoleName -and $_.AllowedMemberTypes -contains "Application"}

# Assign the role to the managed identity.
New-MgServicePrincipalAppRoleAssignment `
  -ServicePrincipalId $managedIdentityObjectId `
  -PrincipalId $managedIdentityObjectId `
  -ResourceId $graphServicePrincipal.Id `
  -AppRoleId $graphApiAppRole.Id
```

## Deploy the Bicep file or template

After creating the managed identity and assigning it permission, you can use it in the Bicep or template file deployment.

PowerShell with Azure cmdlets:

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile main.bicep `
  -ManagedIdentityName $managedIdentityName `
  -AzureADApplicationName MyApp
```

Azure CLI with Bash:

```bash
az deployment group create \
  --resource-group $resourceGroupName \
  --template-file main.bicep \
  --parameters managedIdentityName=$managedIdentityName azureADApplicationName=MyApp
```
`Tags: `