function LogError($e, $message) {
    Write-Host "$message"
    Write-Host -Object $e
    Write-Host -Object $e.ScriptStackTrace
}

function RunWithRetries(
    [ScriptBlock] $runBlock, 
    [ScriptBlock] $onFailureBlock = {}, 
    [int] $retryAttempts = 5, 
    [int] $waitBeforeRetrySeconds = 30,
    [bool] $ignoreFailure = $false,
    [switch] $exponentialBackoff
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
                    LogError $_ "[WARN] Ignoring the failure"
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
