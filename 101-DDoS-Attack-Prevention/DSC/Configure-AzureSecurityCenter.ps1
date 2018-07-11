
[CmdletBinding()]
param (

    [Parameter(Mandatory = $true,
        HelpMessage = "Provide email address for recieving alerts from Azure Security Center.")]
    [Alias("email")]
    [string]
    $EmailAddressForAlerts

)

# Enable ASC Policies

$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
Write-Verbose "Checking AzureRM context for Azure security center configuration."
$currentAzureContext = Get-AzureRmContext
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)

Write-Verbose "Getting access token for Azure security center."
Write-Verbose("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
$token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
$token = $token.AccessToken
$Script:asc_clientId = "1950a258-227b-4e31-a9cf-717495945fc2"              # Well-known client ID for Azure PowerShell
$Script:asc_redirectUri = "urn:ietf:wg:oauth:2.0:oob"                      # Redirect URI for Azure PowerShell
$Script:asc_resourceAppIdURI = "https://management.azure.com/"             # Resource URI for REST API
$Script:asc_url = 'management.azure.com'                                   # Well-known URL endpoint
$Script:asc_version = "2015-06-01-preview"                                 # Default API Version
$PolicyName = 'default'
$asc_APIVersion = "?api-version=$asc_version" #Build version syntax.
$asc_endpoint = 'policies' #Set endpoint.

Write-Verbose "Creating authentication header."
Set-Variable -Name asc_requestHeader -Scope Script -Value @{"Authorization" = "Bearer $token"}
Set-Variable -Name asc_subscriptionId -Scope Script -Value $currentAzureContext.Subscription.Id

#Retrieve existing policy and build hashtable
Write-Verbose "Retrieving data for $PolicyName..."
$asc_uri = "https://$asc_url/subscriptions/$asc_subscriptionId/providers/microsoft.Security/$asc_endpoint/$PolicyName$asc_APIVersion"
$asc_request = Invoke-RestMethod -Uri $asc_uri -Method Get -Headers $asc_requestHeader
$a = $asc_request 
$json_policy = @{
    properties = @{
        policyLevel                  = $a.properties.policyLevel
        policyName                   = $a.properties.name
        unique                       = $a.properties.unique
        logCollection                = $a.properties.logCollection
        recommendations              = $a.properties.recommendations
        logsConfiguration            = $a.properties.logsConfiguration
        omsWorkspaceConfiguration    = $a.properties.omsWorkspaceConfiguration
        securityContactConfiguration = $a.properties.securityContactConfiguration
        pricingConfiguration         = $a.properties.pricingConfiguration
    }
}

#Set all params to on,
$json_policy.properties.recommendations.patch = "On"
$json_policy.properties.recommendations.baseline = "On"
$json_policy.properties.recommendations.antimalware = "On"
$json_policy.properties.recommendations.diskEncryption = "On"
$json_policy.properties.recommendations.acls = "On"
$json_policy.properties.recommendations.nsgs = "On"
$json_policy.properties.recommendations.waf = "On"
$json_policy.properties.recommendations.sqlAuditing = "On"
$json_policy.properties.recommendations.sqlTde = "On"
$json_policy.properties.recommendations.ngfw = "On"
$json_policy.properties.recommendations.vulnerabilityAssessment = "On"
$json_policy.properties.recommendations.storageEncryption = "On"
$json_policy.properties.recommendations.jitNetworkAccess = "On"
$json_policy.properties.recommendations.appWhitelisting = "On"
$json_policy.properties.securityContactConfiguration.areNotificationsOn = $true
$json_policy.properties.securityContactConfiguration.sendToAdminOn = $true
$json_policy.properties.logCollection = "On"
$json_policy.properties.pricingConfiguration.selectedPricingTier = "Standard"
try {
    $json_policy.properties.securityContactConfiguration.securityContactEmails = $EmailAddressForAlerts
}
catch {
    $json_policy.properties.securityContactConfiguration | Add-Member -NotePropertyName securityContactEmails -NotePropertyValue $EmailAddressForAlerts
}
Start-Sleep 5

Write-Verbose "Enabling ASC Policies.."
$JSON = ($json_policy | ConvertTo-Json -Depth 3)
$asc_uri = "https://$asc_url/subscriptions/$asc_subscriptionId/providers/microsoft.Security/$asc_endpoint/$PolicyName$asc_APIVersion"
Invoke-WebRequest -Uri $asc_uri -Method Put -Headers $asc_requestHeader -Body $JSON -UseBasicParsing -ContentType "application/json"

