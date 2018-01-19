[cmdletbinding()]
param(

	[string]$appName = "rds-update-certificate-script",

	# has to be a valid format URI; URI's not validated for single-tenant application
	[string]$uri = "https://login.microsoft.com/rds-update-certificate-script",
	
	[parameter(mandatory=$true)]
	[string]$password,

	[string]$vaultName
)

$app = New-AzureRmADApplication -DisplayName $appName -HomePage $uri -IdentifierUris $uri -password $pwd

$sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

if ($vaultName)
{
	set-azurermkeyvaultaccesspolicy -vaultname $vaultName -serviceprincipalname $sp.ApplicationId -permissionstosecrets get
}

$tenantId = (get-azurermsubscription).TenantId | select -Unique


# outputs
#
"application id:  $($app.ApplicationId)"
"tenant id:       $tenantId"
