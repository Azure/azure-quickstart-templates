<#
.DESCRIPTION
    Installs a set of WinGet packages. Relies on windows-install-winget being executed prior to this script.
.PARAMETER Packages
    Packages to install in the format 'package-id-1[@version-1],package-id-2[@version-2],...'.
.PARAMETER IgnorePackageInstallFailures
    Allows ignoring failures while installing individual packages and let image creation to continue to be able to inspect logs.
.EXAMPLE
        Sample Bicep snippet for using the artifact:

        // WinGet packages to install for all users during image creation.
        // To discover ids of WinGet packages use 'winget search' command.
        // To check whether a package supports machine-wide install run 'winget show --scope Machine --id <package-id>'
        var winGetPackageIds = [
          'WinDirStat.WinDirStat@1.1.2'
          'Kubernetes.kubectl'
          'Microsoft.Azure.AZCopy.10'
        ]

        var additionalArtifacts = [
        {
            name: 'windows-install-winget-packages'
            parameters: {
            packages: join(winGetPackageIds, ',')
          }
        }
#>

param
(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $Packages,
    [Parameter(Mandatory = $false)] [bool] $IgnorePackageInstallFailures = $false
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

function Invoke-Executable {
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $commandLine
    )

    Write-Host "--- Invoking $commandLine"
    & ([ScriptBlock]::Create($commandLine))
}

function Install-WinGet-Packages {
    param (
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $Packages,
        [Parameter(Mandatory = $false)] [bool] $IgnorePackageInstallFailures
    )

    Write-Host "=== Microsoft.DesktopAppInstaller package info: $(Get-AppxPackage Microsoft.DesktopAppInstaller | Out-String)"

    $winGetAppInfo = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if (!$winGetAppInfo) {
        throw 'Could not locate winget.exe'
    }

    $winGetPath = $winGetAppInfo.Path
    Write-Host "=== Found $winGetPath ; 'winget.exe --info' output: $(Invoke-Executable "$winGetPath --info" | Out-String)"

    $packagesArray = @($Packages -Split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    Write-Host "=== Installing $($packagesArray.Count) package(s)"

    $script:successfullyInstalledCount = 0
    foreach ($package in $packagesArray) {
        Write-Host "=== Installing package $package"
        $packageInfoParts = @($package -Split '@' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })

        $packageId = $packageInfoParts[0]
        $versionArg = ''
        if ($packageInfoParts.Count -gt 2) {
            throw "Unexpected format for package $package. Expected format is package-id[@version]"
        }
        elseif ($packageInfoParts.Count -eq 2) {
            $versionArg = "--version $($packageInfoParts[1])"
        }

        $runBlock = {
            $global:LASTEXITCODE = 0
            Invoke-Executable "$WinGetPath install --id $packageId $versionArg --exact --disable-interactivity --silent --no-upgrade --accept-package-agreements --accept-source-agreements --verbose-logs --scope machine --force"
            if ($global:LASTEXITCODE -ne 0) {
                throw "Failed to install $package with exit code $global:LASTEXITCODE. WinGet return codes are listed at https://github.com/microsoft/winget-cli/blob/master/doc/windows/package-manager/winget/returnCodes.md"
            }

            $script:successfullyInstalledCount++
        }

        RunWithRetries -runBlock $runBlock -retryAttempts 5 -waitBeforeRetrySeconds 1 -ignoreFailure $IgnorePackageInstallFailures
    }

    Write-Host "=== Successfully installed $script:successfullyInstalledCount of $($packagesArray.Count) package(s)"

    Write-Host "=== Granting read and execute permissions to BUILTIN\Users on $env:ProgramFiles\WinGet\Packages"
    Invoke-Executable "$env:SystemRoot\System32\icacls.exe ""$env:ProgramFiles\WinGet\Packages"" /t /q /grant ""BUILTIN\Users:(rx)"""

    # Backup latest WinGet logs to allow inspection on a Dev Box VM
    $winGetLogsDir = 'C:\.tools\Setup\Logs\WinGet'
    mkdir $winGetLogsDir -ErrorAction SilentlyContinue | Out-Null
    Invoke-Executable "robocopy.exe /R:5 /W:5 /S $env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir $winGetLogsDir"
    & cmd.exe /c "echo Reset last exit code to 0"
}

if ((-not (Test-Path variable:global:IsUnderTest)) -or (-not $global:IsUnderTest)) {
    try {
        Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')
        Install-WinGet-Packages -Packages $Packages -IgnorePackageInstallFailures $IgnorePackageInstallFailures
    }
    catch {
        Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
    }
}
