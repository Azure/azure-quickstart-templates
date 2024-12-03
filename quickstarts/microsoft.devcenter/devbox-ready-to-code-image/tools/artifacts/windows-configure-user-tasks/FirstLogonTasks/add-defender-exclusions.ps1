<#
.DESCRIPTION
    Add Windows Defender exclusion that can access user local environment variables.
    Related: https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/configure-extension-file-exclusions-microsoft-defender-antivirus?view=o365-worldwide#system-environment-variables
.EXAMPLE
    Sample Bicep snippet for adding the task via Dev Box Image Templates:

    {
        Task: 'add-defender-exclusions'
        Parameters: {
            DirsToExclude: [
                '%TEMP%\\CloudStore'
                '%TEMP%\\NuGetScratch'
                '%TEMP%\\MSBuildTemp%USERNAME%'
            ]
    }
#>

param(
    [Parameter(Mandatory = $true)][PSObject] $TaskParams
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
    foreach ($dir in $TaskParams.DirsToExclude) {
        $expandedDir = [Environment]::ExpandEnvironmentVariables($dir)
        Add-MpPreference -ExclusionPath $expandedDir
        Write-Host "Added Windows Defender exlusion for $expandedDir"
    }
}
catch {
    Write-Host "!!! [WARN] Unhandled exception (will be ignored):"
    Write-Host -Object $_
    Write-Host -Object $_.ScriptStackTrace
}
