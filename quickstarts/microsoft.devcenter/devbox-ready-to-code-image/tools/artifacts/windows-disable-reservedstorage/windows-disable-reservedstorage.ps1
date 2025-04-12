<#
.SYNOPSIS
    Uses DISM to disable Reserved Storage.
.DESCRIPTION
     Checks current state of Reserved Storage and if enabled will disable it using DISM command Set-ReservedStorageState.
.EXAMPLE
    Sample Bicep snippet for using the artifact:

    {
      name: 'windows-disable-reservedstorage'
    }
#>

param(
    [Parameter(Mandatory = $false)] [bool] $IgnoreFailure = $false
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$onFailureBlock = {
    $dismLog = 'C:\WINDOWS\Logs\DISM\dism.log'
    $logTailLines = 200
    if (Test-Path -Path $dismLog -PathType Leaf) {
        Write-Host "=== Tail of $dismLog :"
        try {
            Get-Content $dismLog -Tail $logTailLines
        }
        catch {
            LogError $_ "[WARN] Failed to read $dismLog"
        }
    }
}

try {
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')

    Write-Host "Using DISM to disable Reserved Storage."

    # DISM command below was seen to keep failing with the error below for as long as 5 minutes. 
    #   "This operation is not supported when reserved storage is in use. Please wait for any servicing operations to complete and then try again later."
    # Leaving Reserved Storage enabled is undesirable because it could extent Dev Box provisioning time by 15-20 minutes. Therefore keep waiting for a while before failing.
    RunWithRetries -retryAttempts 10 -waitBeforeRetrySeconds 2 -exponentialBackoff -runBlock {
        $dismExitCode = (Start-Process -FilePath "DISM.exe" -ArgumentList "/Online /Set-ReservedStorageState /State:Disabled" -Wait -Passthru -NoNewWindow).ExitCode 
        if ($dismExitCode -ne 0) { 
            throw "DISM command failed with exit code $dismExitCode" 
        }
        Write-Host "Reserved Storage has been disabled." 
    } -onFailureBlock $onFailureBlock -ignoreFailure $IgnoreFailure
}
catch {
    Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
}