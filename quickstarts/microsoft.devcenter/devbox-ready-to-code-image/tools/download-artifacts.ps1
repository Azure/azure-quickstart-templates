$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

function Get-ManagedIdentityAccessToken {
    param(
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $resource
    )

    $resourceEscaped = [uri]::EscapeDataString($resource)
    $requestUri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=$resourceEscaped"
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
    return (Get-ManagedIdentityAccessToken '499b84ac-1321-427f-aa17-267ca6975798')
}

$toolsRoot = "C:\.tools\Setup"
mkdir $toolsRoot -Force | Out-Null
$zip = "$toolsRoot\artifacts.zip"

if ($scriptsRepoUrl.StartsWith('https://github.com/')) {
    Write-Host "=== Downloading artifacts from branch $scriptsRepoBranch of repo $scriptsRepoUrl"
    $requestUri = "$scriptsRepoUrl/archive/refs/heads/$scriptsRepoBranch.zip"
    Invoke-RestMethod -Uri $requestUri -Method Get -OutFile $zip

    $expandedArchiveRoot = "$toolsRoot\tmp"
    Write-Host "-- Extracting to $expandedArchiveRoot"
    mkdir $expandedArchiveRoot -Force | Out-Null
    Expand-Archive -Path $zip -DestinationPath $expandedArchiveRoot

    $expandedScriptsPath = [IO.Path]::GetFullPath($(Join-Path $((Get-ChildItem $expandedArchiveRoot)[0].FullName) $scriptsRepoPath))
    Write-Host "-- Moving $expandedScriptsPath to $toolsRoot"
    Move-Item -Path $expandedScriptsPath -Destination $toolsRoot

    Write-Host "-- Deleting temp files"
    Remove-Item -Path $expandedArchiveRoot -Recurse -Force

}
elseif ($scriptsRepoUrl.StartsWith('https://dev.azure.com/')) {
    Write-Host "=== Downloading artifacts from $scriptsRepoPath of branch $scriptsRepoBranch in repo $scriptsRepoUrl"
    $requestUri = "$scriptsRepoUrl/items?path=$scriptsRepoPath&`$format=zip&versionDescriptor.version=$scriptsRepoBranch&versionDescriptor.versionType=branch&api-version=5.0-preview.1"
    $aadToken = Get-AzureDevOpsAccessToken
    Invoke-RestMethod -Uri $requestUri -Method Get -Headers @{"Authorization" = "Bearer $aadToken" } -OutFile $zip

    Write-Host "-- Extracting to $toolsRoot"
    Expand-Archive -Path $zip -DestinationPath $toolsRoot
    Remove-Item -Path $zip -Force
}
else {
    throw "Don't know how to download files from repo $scriptsRepoUrl"
}

Write-Host "-- Content of $toolsRoot"
Get-ChildItem $toolsRoot -Recurse

Write-Host "=== Completed downloading artifacts"
