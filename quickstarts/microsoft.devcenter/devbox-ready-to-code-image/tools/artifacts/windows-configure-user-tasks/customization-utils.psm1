$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function LogWithTimestamp([string] $message) {
    Write-Host "$(Get-Date -Format "[yyyy-MM-dd HH:mm:ss.fff]") $message"
}
