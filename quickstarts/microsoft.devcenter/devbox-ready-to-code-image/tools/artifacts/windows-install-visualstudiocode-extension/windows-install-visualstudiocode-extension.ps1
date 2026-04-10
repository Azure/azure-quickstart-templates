<#
.SYNOPSIS
    Installs a Visual Studio Code extension
.DESCRIPTION
    Installs the provided Visual Studio Code extension by id or name to the given installation of VS Code
.PARAMETER ExtensionId
    Visual Studio Code Marketplace identifier for the extension. Cannot be defined if ExtensionName or ExtensionVsixPath is defined
.PARAMETER ExtensionName
    Visual Studio Code Marketplace name identifier for the extension. Cannot be defined if ExtensionId or ExtensionVsixPath is defined
.PARAMETER ExtensionVsixPath
    File path or URL to the extension VSIX file. Cannot be defined if ExtensionName or ExtensionId is defined
.PARAMETER ExtensionVersion
    Version of extension to install, or latest if unspecified. Only applicable when ExtensionName or ExtensionId is set.
.PARAMETER VisualStudioCodeInstallPath
    The location of the Visual Studio Code install (optional, defaults to the global install location)
.PARAMETER EmitAllInstalledExtensions
    After the install operation, emit all extensions installed globally and their versions (default: false)
.EXAMPLE
    Sample Bicep snippet for using the artifact:
    {
      name: 'windows-install-visualstudiocode-extension'
      parameters: {
        ExtensionName: 'GitHub.copilot'
      }
    }
#>

param(
    [Parameter(Mandatory = $false)] [String] $ExtensionId,
    [Parameter(Mandatory = $false)] [String] $ExtensionName,
    [Parameter(Mandatory = $false)] [String] $ExtensionVsixPath,
    [Parameter(Mandatory = $false)] [String] $ExtensionVersion,
    [Parameter(Mandatory = $false)] [String] $VisualStudioCodeInstallPath,
    [Parameter(Mandatory = $false)] [bool] $InstallInsiders = $false,
    [Parameter(Mandatory = $false)] [bool] $EmitAllInstalledExtensions = $false
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-visual-studio-marketplace-utils.psm1')

# Function: Confirm-UserRequest
# Description: Validate that exactly one of ExtensionId, ExtensionName, or ExtensionVsixPath is provided
function Confirm-UserRequest (
    [Parameter(Mandatory = $false)] [String] $extensionId = $null,
    [Parameter(Mandatory = $false)] [String] $extensionName = $null,
    [Parameter(Mandatory = $false)] [String] $extensionVsixPath = $null,
    [Parameter(Mandatory = $false)] [String] $extensionVersion = $null) {

    $paramCount = 0
    if (-not [string]::IsNullOrWhiteSpace($extensionId)) { $paramCount++ }
    if (-not [string]::IsNullOrWhiteSpace($extensionName)) { $paramCount++ }
    if (-not [string]::IsNullOrWhiteSpace($extensionVsixPath)) { $paramCount++ }

    if ($paramCount -ne 1) {
        Write-Error "You must provide either an ExtensionId, ExtensionName, or ExtensionVsixPath (but not more than one). You can find the ExtensionName in the URL of the Marketplace extension. Example: If the extension URL is https://marketplace.visualstudio.com/items?itemName=GitHub.copilot then you would use `GitHub.copilot`."
    }
    
    if ((-not [string]::IsNullOrWhiteSpace($extensionVsixPath)) -and (-not [string]::IsNullOrWhiteSpace($extensionVersion))) {
        Write-Error "You cannot specify an ExtensionVersion when installing from a direct VSIX URL or path."
    }
}

# Function: Import-ExtensionToLocalPath
# Description: Downloads the user requested extension from the VS Code Marketplace, remote url, or a local path.
function Import-ExtensionToLocalPath (
    [Parameter(Mandatory = $false)] [String] $extensionId = $null,
    [Parameter(Mandatory = $false)] [String] $extensionName = $null,
    [Parameter(Mandatory = $false)] [String] $extensionVsixPath = $null,
    [Parameter(Mandatory = $false)] [String] $extensionVersion = $null,
    [Parameter(Mandatory = $true)] [String] $downloadLocation,
    [Parameter(Mandatory = $false)] [Bool] $downloadPreRelease) {

    # Process direct URLs and local path references to extensions
    if (-not [string]::IsNullOrWhiteSpace($extensionVsixPath)) {
        Write-Host "ExtensionVsixPath: $extensionVsixPath"

        if ($extensionVsixPath -match '^https://') {
            try {
                $fileName = [System.IO.Path]::GetFileName($extensionVsixPath)
                if (-not $fileName.EndsWith(".vsix")) {
                    $fileName += ".vsix"
                }

                $savedPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), $fileName)
                Import-RemoteVisualStudioPackageToPath -VsixUrl $extensionVsixPath -LocalFilePath $savedPath
                Copy-Item -Path $savedPath -Destination $downloadLocation
            }
            catch {
                Write-Error "Failed to download the VSIX file from: $extensionVsixPath. $_"
            }
        }
        elseif (-Not (Test-Path $extensionVsixPath)) {
            Write-Error "The specified file path does not exist: $extensionVsixPath."
        }
        else {
            Write-Host "Copying VSIX from local path: $extensionVsixPath"
            Copy-Item -Path $extensionVsixPath -Destination $downloadLocation
            Write-Host "Copied VSIX to: $downloadLocation"
        }
    }
    # Process extension name
    elseif (-not [string]::IsNullOrWhiteSpace($extensionName)) {
        Write-Host "ExtensionName: $extensionName"
        Get-VisualStudioExtension -ExtensionReference $extensionName `
            -VersionNumber $extensionVersion `
            -DownloadLocation $downloadLocation `
            -DownloadDependencies $true `
            -DownloadPreRelease $downloadPreRelease
    }
    # Process extension id
    else {
        Write-Host "ExtensionId: $extensionId"
        Get-VisualStudioExtension -ExtensionReference $extensionId `
            -VersionNumber $extensionVersion `
            -DownloadLocation $downloadLocation `
            -DownloadDependencies $true `
            -DownloadPreRelease $downloadPreRelease
    }
}

# Function: Resolve-VisualStudioCodeBootstrapPath
# Description: Determines the location of the VS Code install's bootstrap extension directory based on user inputs.
# Parameters:
#   - visualStudioCodeInstallPath (string, optional): A custom VS Code install location root.
#   - installInsiders (bool, optional): If using the default install location, request VS Code insiders.
function Resolve-VisualStudioCodeBootstrapPath (
    [Parameter(Mandatory = $false)] [String] $visualStudioCodeInstallPath = $null,
    [Parameter(Mandatory = $false)] [bool] $installInsiders = $false) {

    if ([string]::IsNullOrWhiteSpace($visualStudioCodeInstallPath)) {
        if ($installInsiders) {
            $visualStudioCodeInstallPath = "%ProgramFiles%\Microsoft VS Code Insiders"
        }
        else {
            $visualStudioCodeInstallPath = "%ProgramFiles%\Microsoft VS Code"
        }
    }

    $visualStudioCodeInstallPath = [System.Environment]::ExpandEnvironmentVariables($visualStudioCodeInstallPath)

    if (-not (Test-Path $visualStudioCodeInstallPath)) {
        Write-Error "Visual Studio Code install path was not found at $VisualStudioCodeInstallPath. Ensure the windows-vscodeinstall artifact is executed before this or manually define the install path via the property VisualStudioCodeInstallPath"
    }
    
    return Join-Path -Path $visualStudioCodeInstallPath -ChildPath "bootstrap\extensions"
}

function Main (
    [Parameter(Mandatory = $false)] [String] $extensionId = $null,
    [Parameter(Mandatory = $false)] [String] $extensionName = $null,
    [Parameter(Mandatory = $false)] [String] $extensionVsixPath = $null,
    [Parameter(Mandatory = $false)] [String] $extensionVersion = $null,
    [Parameter(Mandatory = $false)] [String] $visualStudioCodeInstallPath = $null,
    [Parameter(Mandatory = $false)] [bool] $installInsiders = $false,
    [Parameter(Mandatory = $false)] [bool] $emitAllInstalledExtensions = $false) {

    Confirm-UserRequest -extensionId $extensionId `
        -extensionName $extensionName `
        -extensionVsixPath $extensionVsixPath `
        -extensionVersion $extensionVersion

    $vsCodeGlobalExtensionsPath = Resolve-VisualStudioCodeBootstrapPath

    if (-not (Test-Path $vsCodeGlobalExtensionsPath)) {
        New-Item $vsCodeGlobalExtensionsPath -ItemType Directory -ErrorAction 'SilentlyContinue' | Out-Null

        if (-not (Test-Path $vsCodeGlobalExtensionsPath)) {
            Write-Error "The folder $vsCodeGlobalExtensionsPath could not be created. Please ensure you are running as admin."
        }
    }
    
    Import-ExtensionToLocalPath -extensionId $extensionId `
        -extensionName $extensionName `
        -extensionVsixPath $extensionVsixPath `
        -extensionVersion $extensionVersion `
        -downloadLocation $vsCodeGlobalExtensionsPath `
        -downloadPreRelease $installInsiders

    if ($emitAllInstalledExtensions) {
        Write-Host "All extensions in the bootstrap directory:"
        Get-ChildItem -Path $vsCodeGlobalExtensionsPath -File
    } 
}

try {
    if (-not ((Test-Path variable:global:IsUnderTest) -and $global:IsUnderTest)) {
        Main -extensionId $ExtensionId `
            -extensionName $ExtensionName `
            -extensionVsixPath $ExtensionVsixPath `
            -extensionVersion $ExtensionVersion `
            -visualStudioCodeInstallPath $VisualStudioCodeInstallPath `
            -installInsiders $InstallInsiders `
            -emitAllInstalledExtensions $EmitAllInstalledExtensions
    }
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
