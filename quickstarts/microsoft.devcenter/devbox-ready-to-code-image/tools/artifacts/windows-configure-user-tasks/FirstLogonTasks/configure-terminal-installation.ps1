<#
.DESCRIPTION
    Configures terminal installation.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
  
    Write-Host "=== Ensure that Microsoft.WindowsTerminal is registered for the current user"
    Get-AppxPackage -AllUsers Microsoft.WindowsTerminal
    $packageManifest = Get-AppxProvisionedPackage -Online | Where-Object -Property DisplayName -eq 'Microsoft.WindowsTerminal' | Select-Object -ExpandProperty InstallLocation
    Add-AppxPackage -Path $packageManifest -Register -DisableDevelopmentMode -ForceApplicationShutdown
    Get-AppxPackage Microsoft.WindowsTerminal   # Now should be registered for the current user
    
}
catch {
    Write-Host "[WARN] Unhandled exception (will be ignored):"
    Write-Host -Object $e
    Write-Host -Object $e.ScriptStackTrace
}
