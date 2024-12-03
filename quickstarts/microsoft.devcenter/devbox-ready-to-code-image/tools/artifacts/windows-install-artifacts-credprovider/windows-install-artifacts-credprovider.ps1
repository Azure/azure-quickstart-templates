<#
.SYNOPSIS
    Installs the Azure Artifact Credential Provider
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [bool] $addNetFx,
    [Parameter(Mandatory = $false)]
    [bool] $installNet6 = $true,
    [Parameter(Mandatory = $false)]
    [string] $version,
    [Parameter(Mandatory = $false)]
    [string] $optionalCopyNugetPluginsRoot
)

Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')

$downloadUrl = "https://aka.ms/install-artifacts-credprovider.ps1"
$outputFile = [System.IO.Path]::Combine($env:TEMP, "installcredprovider.ps1")

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if (Test-Path -PathType Container $outputFile) {
        [System.IO.Directory]::Delete($outputFile, $true)
    }

    Write-Host "Downloading Artifact Credential provider install script from $downloadUrl."
    Write-Host "Writing file to $outputFile"
    $runBlock = {
        Invoke-WebRequest -Uri "$downloadUrl" -OutFile "$outputFile"
    }
    RunWithRetries -runBlock $runBlock -retryAttempts 5 -waitBeforeRetrySeconds 5

    if (!(Test-Path -PathType Leaf $outputFile)) {
        Write-Error "File download failed."
        exit 1
    }

    Write-Host "Running install script."

    if ($addNetFx -eq $true) {
        Write-Host "Installing with NetFx."
    }
    else {
        Write-Host "Installing NetCore only."
    }

    if ($installNet6 -eq $true) {
        Write-Host "Installing .NET 6.0."
    }
    else {
        Write-Host "Installing .NET Core 3.1."
    }

    if (![string]::IsNullOrEmpty($version)) {
        Write-Host "Installing version $version"
    }

    $runBlock = {
        &$outputFile -AddNetFx:$addNetFx -InstallNet6:$installNet6 -Version:$version
    }
    RunWithRetries -runBlock $runBlock -retryAttempts 5 -waitBeforeRetrySeconds 5

    $nugetPluginDirectory = [System.IO.Path]::Combine($env:USERPROFILE, ".nuget", "plugins")
    $expectedNetCoreLocation = [System.IO.Path]::Combine($nugetPluginDirectory, "netcore\CredentialProvider.Microsoft\CredentialProvider.Microsoft.dll")
    if (!(Test-Path -PathType Leaf $expectedNetCoreLocation)) {
        Write-Host "Credential Provider (NetCore) not found at $expectedNetCoreLocation."
        exit 1
    }

    $expectedNetFXLoacation = [System.IO.Path]::Combine($nugetPluginDirectory, "netfx\CredentialProvider.Microsoft\CredentialProvider.Microsoft.exe")
    if ($addNetFx -eq $true -and !(Test-Path -PathType Leaf $expectedNetFXLoacation)) {
        Write-Host "Credential Provider (NetFx) not found at $expectedNetFXLoacation."
        exit 1
    }

    if (!([System.String]::IsNullOrWhiteSpace($optionalCopyNugetPluginsRoot))) {
        $targetDirectory = [System.IO.Path]::Combine($optionalCopyNugetPluginsRoot, ".nuget", "plugins")
        # Create the target if it doesn't exist
        if (!(Test-Path -PathType Container $targetDirectory)) {
            Write-Host "Creating directory '$targetDirectory'."
            [System.IO.Directory]::CreateDirectory($targetDirectory)
        }

        # If it still doesn't exist, throw an error
        if (!(Test-Path -PathType Container $targetDirectory)) {
            Write-Error "Could not create folder '$targetDirectory'."
            exit 1
        }

        Write-Host
        Write-Host "Copying NuGet plugins from '$nugetPluginDirectory' to '$targetDirectory'."
        Copy-Item -Path "$nugetPluginDirectory\*" -Destination "$targetDirectory\" -Recurse -Force
    }

    exit 0
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}

