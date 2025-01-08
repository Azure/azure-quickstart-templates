<#
.SYNOPSIS
    Enable and disable setting in Windows update.
.DESCRIPTION
    This script enables the following settings:
        - Notify me when a restart is required to finish updating.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
    Write-Host "Windows update settings are being configured ..."
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'RestartNotificationsAllowed2' -Value 1
    Write-Host "Windows update settings complete"
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
