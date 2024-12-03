param(
# Represents a specific build version. The possible values are:
#   latest - Latest build on the channel (used with the -Channel option).
#   Three-part version in X.Y.Z format representing a specific build version; 
#      supersedes the -Channel option. For example: 2.0.0-preview2-006120.
[string]$DotNetCoreVersion = "latest",

# Installs just the shared runtime, not the entire SDK. The possible values are:
#   dotnet - the Microsoft.NETCore.App shared runtime, 
#   aspnetcore - the Microsoft.AspNetCore.App shared runtime, 
#   windowsdesktop - the Microsoft.WindowsDesktop.App shared runtime.
[string]$Runtime,

# Specifies the source channel for the installation. The possible values are:
#   Current - Most current release.
#   LTS - (default) Long-Term Support channel (most current supported release).
#   Two-part version in X.Y format representing a specific release (for example, 2.1 or 3.0)
#   Branch name: for example, release/3.1.1xx or master (for nightly releases). 
#      Use this option to install a version from a preview channel. 
#      Use the name of the channel as listed in Installers and Binaries.
[string]$Channel,

# Specifies to use a global.json file to install .NET Core SDK. This overrides any other value set and will install the sdk based on the value in Global.Json
[string]$GlobalJsonFilePath,

# Create Global.Json file to override local dotnet version
[string]$OverrideDotnet

)

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (![string]::IsNullOrEmpty($GlobalJsonFilePath)) {
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-json-utils.psm1')
    if([System.IO.File]::Exists($GlobalJsonFilePath)) {
        $DotNetCoreVersion = (Get-JsonFromFile $GlobalJsonFilePath).sdk.version
    }

    Write-Host "Installing NetCore SDK version: $DotNetCoreVersion"
    & .\dotnet-install.ps1 -Version $DotNetCoreVersion -InstallDir "C:\Program Files\dotnet" 
    exit 0
}

$Override = $false
if ((![string]::IsNullOrEmpty($OverrideDotnet)) -and ($OverrideDotnet -eq "OverrideDotnet")) {
     $Override = $true
}

Write-Host "Installing NetCore SDK version: $DotNetCoreVersion  channel: $Channel  runtime: $Runtime  OverrideDotnet: $OverrideDotnet  Override:$Override"
Unblock-File -Path .\dotnet-install.ps1

if ([string]::IsNullOrEmpty($Channel)) {
    if ([string]::IsNullOrEmpty($Runtime)) {
	    & .\dotnet-install.ps1 -Version $DotNetCoreVersion -InstallDir "C:\Program Files\dotnet" -OverrideVersion $Override
    }
    else {
	    & .\dotnet-install.ps1 -Version $DotNetCoreVersion -InstallDir "C:\Program Files\dotnet" -RunTime $Runtime -OverrideVersion $Override
    }
}
elseif([string]::IsNullOrEmpty($Runtime) -and [string]::IsNullOrEmpty($DotNetCoreVersion))
{
    & .\dotnet-install.ps1 -Channel $Channel -InstallDir "C:\Program Files\dotnet"
}
else
{
    if ([string]::IsNullOrEmpty($Runtime)) {
	    & .\dotnet-install.ps1 -Version $DotNetCoreVersion -Channel $Channel -InstallDir "C:\Program Files\dotnet" -OverrideVersion $Override
    }
    else {
	    & .\dotnet-install.ps1 -Version $DotNetCoreVersion -Channel $Channel -InstallDir "C:\Program Files\dotnet" -RunTime $Runtime -OverrideVersion $Override
    }
}

# https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script