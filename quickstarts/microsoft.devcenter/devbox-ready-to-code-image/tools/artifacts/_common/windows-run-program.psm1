<#
.DESCRIPTION
    Utilities to invoke a program and reliably handle results.
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function LogWithTimestamp([string] $message) {
    Write-Host "$(Get-Date -Format "[yyyy-MM-dd HH:mm:ss.fff]") $message"
}

function Run-Program(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $Program,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $Arguments,
    [Parameter(Mandatory = $false)][bool] $IgnoreExitCode = $false,
    [Parameter(Mandatory = $false)][int] $RetryAttempts = 3
) {
    $attempt = 1
    $progExitCode = 0
    while ($attempt -le $RetryAttempts) {
        LogWithTimestamp "-- Executing command (attempt $attempt): $Program $Arguments"
        # Use Start-Process to reliably capture process exit code and handle input/output redirects in arguments
        $progExitCode = (Start-Process -FilePath $Program -ArgumentList $Arguments -Wait -Passthru -NoNewWindow).ExitCode
        if ($progExitCode -ne 0) {
            $errorMessage = "Command '$Program $Arguments' exited with code $progExitCode"
            if ($IgnoreExitCode -or ($attempt -lt $RetryAttempts)) {
                LogWithTimestamp "[WARN] $errorMessage"
            }
            else {
                LogWithTimestamp "[ERROR] $errorMessage"
                throw $errorMessage
            }
        }
        else {
            break
        }

        $attempt++
        LogWithTimestamp "-- Waiting $attempt seconds before next attempt"
        Start-Sleep -Seconds $attempt
    }

    LogWithTimestamp "-- Completed command: $Program $Arguments"
    return $progExitCode
}
