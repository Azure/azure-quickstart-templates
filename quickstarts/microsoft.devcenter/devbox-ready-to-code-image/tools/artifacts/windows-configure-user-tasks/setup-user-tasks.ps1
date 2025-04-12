<#
.DESCRIPTION
    Configures a set of tasks to execute when a user logs into a VM.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
    $setupScriptsDir = $PSScriptRoot

    Write-Host "=== Register the command to run when user logs in for the very first time"
    $runKey = "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    reg.exe add $runKey /f /v "DevBoxImageTemplates" /t "REG_EXPAND_SZ" /d "powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -WindowStyle Minimized $setupScriptsDir\runonce-user-tasks.ps1"
    reg.exe query $runKey /s
}
catch {
    Write-Host "[WARN] Unhandled exception:"
    Write-Host -Object $_
    Write-Host -Object $_.ScriptStackTrace
}
