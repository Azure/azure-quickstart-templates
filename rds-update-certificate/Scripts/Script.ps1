[cmdletbinding()]
param(
    [parameter(mandatory = $true)][ValidateNotNullOrEmpty()] [string]$appId,
    [parameter(mandatory = $true)][ValidateNotNullOrEmpty()] [string]$appPassword,
    [parameter(mandatory = $true)][ValidateNotNullOrEmpty()] [string]$tenantId,

    [parameter(mandatory = $true)][ValidateNotNullOrEmpty()] [string]$vaultName,
    [parameter(mandatory = $true)][ValidateNotNullOrEmpty()] [string]$secretName,

	[ValidateSet("All", "RDGateway", "RDWebAccess", "RDRedirector", "RDPublishing")]
	[string]$roleName,

    [Parameter(ValueFromRemainingArguments = $true)]
    $extraParameters
    )

    function log
    {
        param([string]$message)

        "`n`n$(get-date -f o)  $message" 
    }


	log "script running..."

	whoami

  # $PSBoundParameters

    if ($extraParameters) 
    {
        log "any extra parameters:"
        $extraParameters
    }

	#  requires WMF 5.0

	#  verify NuGet package
	$nuget = get-packageprovider nuget
	if (-not $nuget -or ($nuget.Version -lt 2.8.5.22))
	{
		log "installing nuget package..."
		install-packageprovider -name NuGet -minimumversion 2.8.5.201 -force
	}

	#  install AzureRM module
	#
	if (-not (get-module AzureRM))
	{
		log "installing azurerm powershell module..."
		install-module AzureRM -force
	}


	#  log onto azure account
	#
	log "logging onto azure account with app id = $appId ..."

	$creds = new-object System.Management.Automation.PSCredential ($appId, (convertto-securestring $appPassword -asplaintext -force))
	login-azurermaccount -credential $creds -serviceprincipal -tenantid $tenantId -confirm:$false

	#  get the secret from key vault
	#
	log "getting secret '$secretName' from keyvault '$vaultName'..."
	$secret = get-azurekeyvaultsecret -vaultname $vaultName -name $secretName

	$pfx = join-path $env:TEMP "$([guid]::NewGuid()).pfx"
	log "writing the cert as '$pfx'..."
	[io.file]::WriteAllBytes($pfx, [System.Convert]::FromBase64String($secret.SecretValueText))

	#  apply certificate
	#
	ipmo remotedesktop -DisableNameChecking  

	if (-not $roleName -or $rolename -like "all") 
	{
		$roles = @("RDGateway", "RDWebAccess", "RDRedirector", "RDPublishing") 
	}
	else
	{
		$roles = @($roleName)	
	}

	$roles | % `
	{
		log "applying certificate for role: $_..."
		set-rdcertificate -role $_ -importpath $pfx -force
	}
	
	#  clean up
	#  
	if (test-path($pfx))
	{
		log "cleanup..."
		remove-item $pfx
	}

	log "done."
	
