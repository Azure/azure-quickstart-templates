# VM BOOTSTORM WORKLOAD FOR AZURE (CLOUD)

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/bootstorm-vm-boot-time/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/bootstorm-vm-boot-time/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/bootstorm-vm-boot-time/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/bootstorm-vm-boot-time/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/bootstorm-vm-boot-time/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/bootstorm-vm-boot-time/CredScanResult.svg" />&nbsp;

## DESCRIPTION

This template deploys requested number of A2 size Windows Server 2012R2 VMs and a controller VM with public IP address in same virtual network. Controller VM turn-off all VMs then boot them simultaneously to measure an average and end-to-end VM boot time.

For controller VM to manage all VMs, Azure SPN needs to be configured using instructions given below.


## AZURE SPN CONFIGURATION

```Poweshell
New-AzureRmADApplication -Password <any string to use as a password> -DisplayName <Any String Name> -IdentifierUris https://<UseAnyUniqueName e.g. serviceprinciplenm> -HomePage <same as IdentifierUris>

<i>Use ApplicationId returned by above cmdlet</i>

New-AzureRmADServicePrincipal -ApplicationId <ApplicationId>

New-AzureRmRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName "https://<same as IdentifierUris>"
```

## SAMPLE AZURE SPN CONFIGURATION COMMANDS

```Poweshell
$azureSubscriptionId = "<Your Azure subscription id (Get-AzureSubscription).SubscriptionId>"

$azureAdIdUri = "https://azureadiduri"

$azureAdPassword = "azureadpwd123"

$azureAdDisplayName = "azureaddisplayname"

Add-AzureRmAccount

Select-AzureRmSubscription -SubscriptionID $azureSubscriptionId

$azureAdApp = New-AzureRmADApplication -Password $azureAdPassword -DisplayName $azureAdDisplayName -IdentifierUris $azureAdIdUri -HomePage $azureAdIdUri

New-AzureRmADServicePrincipal -ApplicationId $azureAdApp.ApplicationId

New-AzureRmRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName $azureAdIdUri
```

## RESULTS

VM bootstorm results file is uploaded to Unique Azure Storage Account ('uniqueStorageAccountName' parameter provided by you) as a blob with name 'VMBootAllResult.log.ps1.zip'

## DEPLOY

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureStack-QuickStart-Templates%2Fmaster%2Fbootstorm-vm-boot-time%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>

## PARAMETERS

```Poweshell
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
```

