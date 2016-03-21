## VM BOOTSTORM WORKLOAD ##

<b>DESCRIPTION</b>

This template deploys requested number of VMs and a controller VM with public IP address in same virtual network. Controller VM turn-off all VMs then boot them simultaneously to measure an average and end-to-end VM boot time.

For controller VM to manage all VMs, Azure SPN needs to be configured using instructions given below.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbootstorm-vm-boot-time%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbootstorm-vm-boot-time%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<b>AZURE SPN CONFIGURATION</b>

New-AzureADApplication -Password <any string to use as a password> -DisplayName <Any String Name> -IdentifierUris https://<UseAnyName e.g. serviceprinciplenm> -HomePage <same as IdentifierUris parameter>

<i>Use ApplicationId returned by above cmdlet</i>

New-AzureADServicePrincipal -ApplicationId <ApplicationId>

New-AzureRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName "https://<same as IdentifierUris parameter>"


<b>SAMPLE AZURE SPN CONFIGURATION COMMANDS</b>

New-AzureADApplication -Password azureadpwd123 -DisplayName azureaddisplayname -IdentifierUris https://azureadiduri -HomePage https://azureadiduri

<i>Use ApplicationId returned by above cmdlet</i>

New-AzureADServicePrincipal -ApplicationId <ApplicationId retured by New-AzureADApplication>

New-AzureRoleAssignment -RoleDefinitionName Owner -ServicePrincipalName https://azureadiduri


<b>RESULTS</b>

VM bootstorm results file is uploaded to Unique Azure Storage Account ('uniqueStorageAccountName' parameter provided by you) as a blob with name 'VMBootAllResult.log.ps1.zip'