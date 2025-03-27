# In PowerShell 5.1 or later, run:
# - To install Pester: Install-Module Pester -Force
# - To execute tests:  Invoke-Pester -Path <path to test file>
# More is at https://pester.dev/docs/quick-start

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Describe "RunWithRetries" {
    BeforeAll {
        Import-Module -Name (Join-Path $(Split-Path -Parent $PSScriptRoot)/_common/windows-retry-utils.psm1) -Force
    }

    BeforeEach {
        function OnFailure() { throw 'must be mocked' }
        Mock OnFailure { Write-Host "OnFailure is called" }

        $script:currentAttempt = 0
        $script:sleepTimes = @()
        Mock -CommandName Start-Sleep -ModuleName windows-retry-utils -MockWith { param ($seconds) $script:sleepTimes += $seconds; Write-Host "Sleeping $seconds seconds" }
    }

    It "DoesNotIgnoreFailure" {
        { RunWithRetries -runBlock { throw 'testing1' } -ignoreFailure $false -retryAttempts 0 -waitBeforeRetrySeconds 0 } | Should -Throw "testing1"
        { RunWithRetries -runBlock { throw 'testing2' } -onFailureBlock { OnFailure } -ignoreFailure $false -retryAttempts 0 -waitBeforeRetrySeconds 0 } | Should -Throw "testing2"
        Should -Invoke OnFailure -Times 1 -Exactly
        $script:sleepTimes | Should -Be @()
    }

    It "IgnoresFailure" {
        { RunWithRetries -runBlock { throw 'testing' } -ignoreFailure $true -retryAttempts 0 -waitBeforeRetrySeconds 0 } | Should -Not -Throw
        { RunWithRetries -runBlock { throw 'testing' } -onFailureBlock { OnFailure } -ignoreFailure $true -retryAttempts 0 -waitBeforeRetrySeconds 0 } | Should -Not -Throw
        Should -Invoke OnFailure -Times 1 -Exactly
        $script:sleepTimes | Should -Be @()
    }

    It "ReportsErrorOnFailure" {
        Mock LogError {}
        RunWithRetries -runBlock { throw 'testing' } -ignoreFailure $true -retryAttempts 0 -waitBeforeRetrySeconds 0
        Should -Invoke LogError -Times 0 -Exactly -ParameterFilter { ($message -eq '[WARN] Ignoring the failure') -and ($e -ne $null) }
        $script:sleepTimes | Should -Be @()
    }

    It "RetriesUntilSuccess" {
        $runBlock = {
            $script:currentAttempt++;
            if ($script:currentAttempt -lt 3) {
                throw 'testing'
            }
        }
        RunWithRetries -runBlock $runBlock -ignoreFailure $false -retryAttempts 2 -waitBeforeRetrySeconds 1
        Should -Invoke OnFailure -Times 0 -Exactly
        $script:currentAttempt | Should -Be 3
        $script:sleepTimes | Should -Be @(1, 1)
    }

    It "RetriesUntilFailure" {
        Mock LogError {}

        $runBlock = {
            $script:currentAttempt++;
            throw 'testing RetriesUntilFailure'
        }

        # Omit -retryAttempts argument to validate the default value
        { RunWithRetries -runBlock $runBlock -onFailureBlock { OnFailure } -ignoreFailure $false -waitBeforeRetrySeconds 0 } `
        | Should -Throw "testing RetriesUntilFailure"
        Should -Invoke OnFailure -Times 1 -Exactly
        Should -Invoke LogError -Times 0 -Exactly
        $script:currentAttempt | Should -Be 6
        $script:sleepTimes | Should -Be @(0, 0, 0, 0, 0) # Five retries with no wait time
    }

    It "ExponentialBackoffWithRetries" {
        $runBlock = {
            $script:currentAttempt++;
            if ($script:currentAttempt -lt 3) {
                throw 'testing'
            }
        }

        RunWithRetries -runBlock $runBlock -ignoreFailure $false -retryAttempts 2 -waitBeforeRetrySeconds 1 -exponentialBackoff

        Should -Invoke OnFailure -Times 0 -Exactly
        $script:currentAttempt | Should -Be 3

        # Validate exponential backoff: 1, 2 seconds (1*2^0, 1*2^1)
        $script:sleepTimes | Should -Be @(1, 2)
    }
}
