$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'   

function getNewestLink($pattern) {
  $uri = "https://api.github.com/repos/microsoft/terminal/releases/latest"
  $get = Invoke-RestMethod -uri $uri -Method Get
  $data = $get[0].assets | Where-Object name -Like $pattern | Select-Object -First 1
  return $data.browser_download_url
}

function RunScriptInstallTerminal() {
  Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')

  Write-Host "Downloading Windows terminal..."
  $terminalPath = "$env:TEMP/terminal.msixbundle"

  $runBlock = {
    $terminalUrl = getNewestLink -pattern '*.msixbundle'
    Invoke-WebRequest -Uri $terminalUrl -OutFile $terminalPath 
  }
  RunWithRetries -runBlock $runBlock -retryAttempts 5 -waitBeforeRetrySeconds 5

  Write-Host "Installing terminal..."
  Add-AppxProvisionedPackage -Online -PackagePath $terminalPath -SkipLicense
}

try {
  RunScriptInstallTerminal
}
catch {
  Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}
