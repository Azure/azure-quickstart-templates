<#
.DESCRIPTION
    Sets up a temporary environment for headless packages restoration and runs the requested script in the environment.
.PARAMETER RepoRoot
    Full path to the repo's root directory.
.PARAMETER RepoPackagesFeed
    Optional ADO Nuget feed URI (even when the repo doesn't use Nuget and only uses NPM for example). The URI is used when restoring packages for the repo. The feed will typically have multiple upstreams.
.PARAMETER AdditionalRepoFeeds
    Optional comma separated list of Nuget feeds that are used during repo setup/build.
.PARAMETER Script
    Passed to 'cmd.exe /c' for execution after the environment for restoring packages is configured.
#>

param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $RepoRoot,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $Script,
    [Parameter(Mandatory = $false)][String] $RepoPackagesFeed,
    [Parameter(Mandatory = $false)] [string] $AdditionalRepoFeeds
)

try {
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    Set-Location $RepoRoot
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-build-environment-utils.psm1')

    SetPackagesRestoreEnvironmentAndRunScript -RepoRoot $RepoRoot -RepoKind Custom -Script $Script `
        -RepoPackagesFeed $RepoPackagesFeed -AdditionalRepoFeeds $AdditionalRepoFeeds 
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}