##################################################################################################
### VM BOOTSTORM ###
##################################################################################################
This template deploys requested number of VMs, plus a controller VM with public IP address, and a Virtual Network. Controller VM then shut-down all VMs then boot them simultaneously to measure an average VM boot time.
For controller VM to manage all VMs, Azure SPN needs to be configured using instructions given below.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdipakmsft%2Fazure-quickstart-templates%2Fmaster%2Fvm-bootstorm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

##################################################################################################
<b>AZURE SPN CONFIGURATION</b>
##################################################################################################
New-AzureADApplication -Password <any string to use as a password> -DisplayName <Any String Name> -IdentifierUris https://<UseAnyName e.g. serviceprinciplenm> -HomePage <same as IdentifierUris parameter>
<i>Use ApplicationId returned by above cmdlet</i>
New-AzureADServicePrincipal -ApplicationId <ApplicationId>
New-AzureRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName "https://<same as IdentifierUris parameter>"

<b>SAMPLE AZURE SPN CONFIGURATION COMMANDS</b>
New-AzureADApplication -Password azureadpwd123 -DisplayName azureaddisplayname -IdentifierUris https://azureadiduri -HomePage https://azureadiduri
<i>Use ApplicationId returned by above cmdlet</i>
New-AzureADServicePrincipal -ApplicationId <ApplicationId retured by New-AzureADApplication>
New-AzureRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName https://azureadiduri

##################################################################################################
<b>RESULTS</b>
##################################################################################################
VM bootstorm results file is uploaded to your Azure Storage Account as a blob with name 'VMBootAllResult.log.ps1.zip'.

##################################################################################################
<b>INVOKE TEMPLATE FROM POWERSHELL</b>
##################################################################################################
Add-AzureRmAccount
Select-AzureRmSubscription -subscriptionID <YourAzureSubscriptionId>
$resourceGroupName = "yourresgrp"
$groupDeploymentName = "yourgrpdep"
$location = "East US 2"
$jobGUID = [System.Guid]::NewGuid().toString()
$templateFile = "<LocationToVMBootstormFiles>\azuredeploy.json"
$templateParamObject = @{
	location = $location
	vmCount = 2
	azureAdApplicationId = "<YourAzureAdAppId returned by New-AzureADApplication cmdlet in Azure SPN Configuration>"
	azureAdApplicationPassword = "<YourAzureAdAppPwd given to New-AzureADApplication cmdlet in Azure SPN Configuration>"
	tenantId = "<YourAzureSubscriptionTenantId>"
}
Remove-AzureResourceGroup -Name $resourceGroupName -Force -ErrorAction Ignore
New-AzureResourceGroup -Name $resourceGroupName -Location $location
New-AzureResourceGroupDeployment -Name $groupDeploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterObject $templateParamObject
