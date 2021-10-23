param(
    [string][Parameter(Mandatory = $true)] $templateFilePath,
    [string][Parameter(Mandatory = $false)] $bearerToken,
    # If this is set, the hash obtained will *not* be the official template hash that Azure would compute.
    [switch][Parameter(Mandatory = $false)] $removeGeneratorMetadata
)

Import-Module "$PSScriptRoot/Local.psm1" -Force

# TODO - this could now be updated to use Invoke-AzRestMethod that handles authn, so token steps could be removed.
if ($bearerToken -eq "") {
    Write-Host "Getting token..."
    Import-Module Az.Accounts
    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $azContext = Get-AzContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
    $bearerToken = ($profileClient.AcquireAccessToken($azContext.Tenant.TenantId)).AccessToken
    if (!$bearerToken) {
        Write-Error "Could not retrieve token"
    }
}
$uri = "https://management.azure.com/providers/Microsoft.Resources/calculateTemplateHash?api-version=2019-10-01"
$Headers = @{
    'Authorization' = "Bearer $bearerToken"
    'Content-Type'  = 'application/json'
}
# END TODO

$raw = Get-Content -Path $templateFilePath -Raw -ErrorAction Stop
if ($RemoveGeneratorMetadata) {
    $withoutGeneratorMetadata = Remove-GeneratorMetadata $raw
}
else {
    $withoutGeneratorMetadata = $raw
}

if ($null -eq $withoutGeneratorMetadata -or $withoutGeneratorMetadata -eq "") {
    Write-Error "JSON is empty"
}

# Get TemplateHash
Write-Host "Requesting Hash for file: $templateFilePath"
try {
    #fail the build for now so we can find issues
    $response = Invoke-RestMethod -Uri $uri `
        -Method "POST" `
        -Headers $Headers `
        -Body $withoutGeneratorMetadata
    $templateHash = $response.templateHash
}
catch {
    Write-Warning $Error[0]
    Write-Warning ($response ? $response : "(no response)")
    Write-Error "Failed to get hash for: $templateFilePath"
}

Write-Host "Template hash: $templateHash"
if (!$templateHash -or !($templateHash -gt 0)) {
    Write-Error "Failed to get hash for: $templateFilePath"
}

Return $templateHash
