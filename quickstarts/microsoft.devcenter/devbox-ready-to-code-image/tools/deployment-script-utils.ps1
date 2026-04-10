$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'

function RunWithRetries(
    [ScriptBlock] $runBlock, 
    [ScriptBlock] $onFailureBlock = {}, 
    [int] $retryAttempts = 5, 
    [int] $waitBeforeRetrySeconds = 5,
    [bool] $ignoreFailure = $false,
    [bool] $exponentialBackoff = $true
) {
    [int] $retriesLeft = $retryAttempts

    while ($retriesLeft -ge 0) {
        try {
            & $runBlock
            break
        }
        catch {
            if ($retriesLeft -le 0) {
                if ($onFailureBlock) {
                    & $onFailureBlock
                }
                if ($ignoreFailure) {
                    Write-Host "[WARN] Ignoring the failure:`n$_`n$($_.ScriptStackTrace)"
                    break
                }
                else {
                    throw
                }
            }
            else {
                if ($exponentialBackoff) {
                    $totalDelay = [Math]::Pow(2, $retryAttempts - $retriesLeft) * $waitBeforeRetrySeconds
                }
                else {
                    $totalDelay = $waitBeforeRetrySeconds
                }
                Write-Host "[WARN] Attempt failed: $_. Retrying in $totalDelay seconds. Retries left: $retriesLeft"
                $retriesLeft--
                Start-Sleep -Seconds $totalDelay
            }
        }
    }
}
