<#
.DESCRIPTION
    Reports information about the current build environment.
    The script is expected to be launched from the same environment from where a build is about to be executed right before its start.
#>

$ErrorActionPreference = "Stop"
$EnvVarExclusionList = @()
Set-StrictMode -Version Latest

try {
    $maxValueLength = 8
    Write-Host "=== Current environment variables (redacted):"
    # Never print full values because they may contain secrets
    Get-ChildItem env: | ForEach-Object { "$($_.Name)=$(if ($_.Name -notin $EnvVarExclusionList) { $(if ($_.Value.Length -gt $maxValueLength) { ""$($_.Value.Substring(0,$maxValueLength))..."" } else { $_.Value }) } else { "<redacted>" })" }
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
