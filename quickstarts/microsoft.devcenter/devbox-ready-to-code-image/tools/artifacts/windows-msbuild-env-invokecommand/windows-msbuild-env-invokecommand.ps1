<#
.DESCRIPTION
    Sets up a temporary environment for headless Nuget packages restoration and runs requested script in the environment.
.PARAMETER RepoRoot
    Full path to the repo's root directory.
.PARAMETER Script
    Passed to 'cmd.exe /c' for execution after the environment for restoring packages is configured.
#>

param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $RepoRoot,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $Script
)

try {
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    # Detect location of msbuild.exe and add it to the path so it can be referenced from the script by just the file name
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-msbuild-utils.psm1')
    $msbuildExeFileDir = Split-Path -Parent (Get-LatestMsbuildLocation)
    $env:PATH += ";$($msbuildExeFileDir);"

    Set-Location $RepoRoot

    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-build-environment-utils.psm1')
    SetPackagesRestoreEnvironmentAndRunScript -RepoRoot $RepoRoot -RepoKind MSBuild -Script $Script
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}