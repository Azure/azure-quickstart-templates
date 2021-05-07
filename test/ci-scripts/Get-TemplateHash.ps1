param(
    [string][Parameter(Mandatory = $true)] $templateFilePath,
    [string][Parameter(Mandatory = $false)] $bearerToken,
    # If this is set, the hash obtained will *not* be the official template hash that Azure would compute.
    [switch][Parameter(Mandatory = $false)] $removeGeneratorMetadata
)
function RemoveGeneratorMetadata(
    [object] $jsonContent
) {
    if ($removeGeneratorMetadata) {
        # Remove the top-level metadata the generator information is there, including the bicep version, and this would
        # affect file comparisons where only the bicep version differs
        $json = ConvertFrom-Json $jsonContent 
        $json.PSObject.properties.remove('metadata')
        return ConvertTo-JSON $json -Depth 100
    }
    else {
        return $jsonContent
    }
}

# TODO - this could now be updated to use Invoke-AzRestMethod that handles authn, so token steps could be removed.
if ($bearerToken -eq "") {
    Write-Host "Getting token..."
    Import-Module Az.Accounts
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $azContext = Get-AzContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
    $bearerToken = ($profileClient.AcquireAccessToken($azContext.Tenant.TenantId)).AccessToken
}
$uri = "https://management.azure.com/providers/Microsoft.Resources/calculateTemplateHash?api-version=2019-10-01"
$Headers = @{
    'Authorization' = "Bearer $bearerToken"
    'Content-Type'  = 'application/json'
}
# END TODO

$raw = Get-Content -Path $templateFilePath -Raw -ErrorAction Stop
$withoutGeneratorMetadata = RemoveGeneratorMetadata $raw -ErrorAction Stop

if ($withoutGeneratorMetadata -eq $null -or $withoutGeneratorMetadata -eq "") {
    Write-Error "JSON is empty"
}

# Get TemplateHash
Write-Host "Requesting Hash for file: $templateFilePath"
try {
    #fail the build for now so we can find issues
    $response = Invoke-RestMethod -Uri $uri `
        -Method "POST" `
        -Headers $Headers `
        -Body $withoutGeneratorMetadata `
        -verbose
    $templateHash = $response.templateHash
}
catch {
    Write-Host $response
    Write-Error "Failed to get hash for: $templateFilePath"
}

Write-Host "Template hash: $templateHash"
if (!($templateHash -gt 0)) {
    Write-Error "Failed to get hash for: $templateFilePath"
}

Return $templateHash
