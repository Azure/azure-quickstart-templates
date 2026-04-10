<#
.DESCRIPTION
    Configures OneDrive sync settings for top level user folders.
#>

param(
    [Parameter(Mandatory = $false)][bool] $EnableDocumentsSync = $true,
    [Parameter(Mandatory = $false)][bool] $EnablePicturesSync = $true,
    # Desktop sync is disabled by default because when multiple Dev Box VMs are used, OneDrive synchronizes its content b/w all of them.
    # This can cause having multiple copies of a shortcut or a file on desktop when they are created by an app installer or build env init scripts.
    [Parameter(Mandatory = $false)][bool] $EnableDesktopSync = $false
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function ConfigureOnedriveSync($enableDocumentsSync, $enablePicturesSync, $enableDesktopSync) {
    try {
        $registryParams = @(
            @{ Key = 'Documents'; Value = if ($enableDocumentsSync) { 1 } else { 0 } },
            @{ Key = 'Desktop'; Value = if ($enableDesktopSync) { 1 } else { 0 } },
            @{ Key = 'Pictures'; Value = if ($enablePicturesSync) { 1 } else { 0 } }
        )

        # Set all keys explicitly because by default OneDrive will sync all three folders if KFMSilentOptIn is present, and it usually is.
        $registryParams | ForEach-Object {
            $registryKey = $_.Key
            $registryValue = $_.Value
            Write-Host "=== Setting registry value: HKLM\SOFTWARE\Policies\Microsoft\OneDrive\KFMSilentOptIn$registryKey = $registryValue"
            reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v "KFMSilentOptIn$registryKey" /t REG_DWORD /d $registryValue /f
        }
    }
    catch {
        Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
    }
}

if (( -not(Test-Path variable:global:IsUnderTest)) -or (-not $global:IsUnderTest)) {
    ConfigureOnedriveSync -enableDocumentsSync $EnableDocumentsSync -enablePicturesSync $EnablePicturesSync -enableDesktopSync $EnableDesktopSync
}
