<#
.DESCRIPTION
    Ensure that WinGet is installed and ready to use for the current user.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) 'customization-utils.psm1')

try {
    $pwsh7Exe = "$($env:ProgramFiles)\PowerShell\7\pwsh.exe"
    & $pwsh7Exe -ExecutionPolicy Bypass -NoProfile -NoLogo -NonInteractive -File (Join-Path $PSScriptRoot 'configure-winget-pwsh7.ps1')
}
catch {
    LogWithTimestamp "!!! [WARN] Unhandled exception (will be ignored):`n$_`n$($_.ScriptStackTrace)"
}
