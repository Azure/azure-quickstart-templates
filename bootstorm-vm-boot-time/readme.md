## VM BOOTSTORM WORKLOAD ##

<b>DESCRIPTION</b>

This template deploys requested number of VMs and a controller VM with public IP address in same virtual network. Controller VM turn-off all VMs then boot them simultaneously to measure an average and end-to-end VM boot time.

For controller VM to manage all VMs, Azure SPN needs to be configured using instructions given below.

<b>AZURE SPN CONFIGURATION</b>

New-AzureADApplication -Password <any string to use as a password> -DisplayName <Any String Name> -IdentifierUris https://<UseAnyName e.g. serviceprinciplenm> -HomePage <same as IdentifierUris parameter>

<i>Use ApplicationId returned by above cmdlet</i>

New-AzureADServicePrincipal -ApplicationId <ApplicationId>

New-AzureRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName "https://<same as IdentifierUris parameter>"


<b>SAMPLE AZURE SPN CONFIGURATION COMMANDS</b>

$azureSubscriptionId = "<Your subscription id>"

$azureAdIdUri = https://azureadiduri

$azureAdPassword = "azureadpwd123"

$azureAdDisplayName = "azureaddisplayname"

Add-AzureAccount

Select-AzureSubscription -SubscriptionID $azureSubscriptionId

Switch-AzureMode AzureResourceManager

$azureAdApp = New-AzureADApplication -Password $azureAdPassword -DisplayName $azureAdDisplayName -IdentifierUris $azureAdIdUri -HomePage $azureAdIdUri;

New-AzureADServicePrincipal -ApplicationId $azureAdApp.ApplicationId;

New-AzureRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName $azureAdIdUri;


<b>RESULTS</b>

VM bootstorm results file is uploaded to Unique Azure Storage Account ('uniqueStorageAccountName' parameter provided by you) as a blob with name 'VMBootAllResult.log.ps1.zip'


<b>DEPLOY</b>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbootstorm-vm-boot-time%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


<b>PARAMETERS</b>
Azure AD Application Id: <Application ID returned by New-AzureADServicePrincipal cmdlet while setting up Azure SPN Configuration>

Azure AD Application Password: <Password you entered for New-AzureADServicePrincipal cmdlet while setting up Azure SPN Configuration>

Tenant Id: (Get-AzureSubscription).TenantId

Unique Dns Name for PublicIP: <Choose any string value unique across Azure>

Unique Storage Account Name: <Choose any string value unique across Azure>

Location: <Location where Azure resources will be deployed>

VM Admin User Name: <Choose secure username for VMs>

VM Admin Password: <Choose secure password for VMs>

VM Count: <Choose number of VMs to deploy>

VM OS Sku: <Choose version of Windows to deploy>