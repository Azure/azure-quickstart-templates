<#
.DESCRIPTION
    Helpers for using Azure Managed Identity
#>

# Caches JWT token when Azure Managed Identity is used to authenticate with Azure DevOps.
$global:azDevOpsAccessToken = ''

function Get-ManagedIdentityAccessToken {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] 
        $resource,

        # The client_id of the managed identity you would like the token for. Required, if your VM has multiple user-assigned managed identities.
        [Parameter()]
        [string]
        $ClientID = $null
    )

    $resourceEscaped = [uri]::EscapeDataString($resource)
    # Get an access token for managed identities for Azure resources
    # Reference - https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-use-vm-token#get-a-token-using-powershell
    $requestUri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=$resourceEscaped"
    
    if (![string]::IsNullOrWhiteSpace($ClientID)) {
        $requestUri += "&client_id=$ClientID"
    }

    Write-Host "Retrieving access token from $requestUri"
    $response = Invoke-WebRequest -Uri $requestUri -Headers @{Metadata = "true" } -UseBasicParsing

    if ($response.Content -imatch "access_token") {
        $jsonContent = $response.Content | ConvertFrom-Json
        $accessToken = $jsonContent.access_token
    }
    else {
        throw "Failed to obtain access token from $requestUri, aborting"
    }

    return $accessToken
}

function Get-AzureDevOpsAccessToken {
    param (
        # The client_id of the managed identity you would like the token for. Required, if your VM has multiple user-assigned managed identities.
        [Parameter()]
        [string]
        $MsiClientID = $null
    )
    return (Get-ManagedIdentityAccessToken -resource '499b84ac-1321-427f-aa17-267ca6975798' -ClientID $MsiClientID)
}

function Get-GitAccessToken {
    param (
        # The client_id of the managed identity you would like the token for. Required, if your VM has multiple user-assigned managed identities.
        [Parameter()]
        [string]
        $MsiClientID = $null
    )
    Write-Host 'Getting token to authenticate with Azure DevOps using Azure Managed Identity assigned to this VM'
    if (!$global:azDevOpsAccessToken) {
        # Request and cache JWT for accessing Azure DevOps resources
        $global:azDevOpsAccessToken = Get-AzureDevOpsAccessToken -MsiClientID $MsiClientID
    }

    return $global:azDevOpsAccessToken
}

function Get-GitAuthorizationHeader {
    param (
        # The client_id of the managed identity you would like the token for. Required, if your VM has multiple user-assigned managed identities.
        [Parameter()]
        [string]
        $MsiClientID = $null
    )
    return "-c http.extraheader=`"Authorization: Bearer $(Get-GitAccessToken -MsiClientID $MsiClientID)`" "
}
