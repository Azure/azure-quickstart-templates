$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function ____ExitOne {
    exit 1
}

function ____Invoke-ImageFactory-Artifact {
    param(
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $____ImageFactoryArtifactName,
        [Parameter(Mandatory = $false)][String] $____ImageFactoryParamsBase64
    )

    # Write-Host "=== Running $PSCommandPath"
    # Get-Content -Raw -Path $PSCommandPath | Write-Host
    # Write-Host "=== End of $PSCommandPath"

    Write-Host "=== Script parameters:"
    $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Host "  $($_.Key) = $($_.Value)" }

    # Convert to a hashtable to be used with splatting
    $private:scriptArgs = @{}
    $private:paramsJson = ''
    if (![String]::IsNullOrEmpty($____ImageFactoryParamsBase64)) {
        $private:paramsJson = $scriptArgsObj = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($____ImageFactoryParamsBase64))
        $private:scriptArgsObj = $private:paramsJson | ConvertFrom-Json
        $private:scriptArgsObj.psobject.properties | ForEach-Object {
            $private:scriptArgs[$_.Name] = switch ($_.Value) {
                'TrUe' { $true }
                'FaLSe' { $false }
                default { $_ -replace '`' }
            }
        }
    }

    $private:scriptPath = Join-Path $PSScriptRoot "$____ImageFactoryArtifactName/$____ImageFactoryArtifactName.ps1"
    Write-Host "=== Invoking $private:scriptPath with arguments: $private:paramsJson"
    try {
        Set-Location -Path (Join-Path $PSScriptRoot $____ImageFactoryArtifactName)
        Write-Host "=== Current location: $(Get-Location)"

        Set-StrictMode -Off
        & $private:scriptPath @private:scriptArgs
        Set-StrictMode -Version Latest

        if ((Test-Path variable:global:LASTEXITCODE) -and ($LASTEXITCODE -ne 0)) {
            throw "Artifact script $private:scriptPath exited with code $LASTEXITCODE"
        }
    }
    catch {
        $exitCodeMsg = ""
        if ((Test-Path variable:global:LASTEXITCODE) -and ($LASTEXITCODE -ne 0)) {
            $exitCodeMsg = " (exit code $LASTEXITCODE)"
        }
        Write-Host "=== Failed$exitCodeMsg to run $private:scriptPath with arguments: $private:paramsJson"
        Write-Host -Object $_
        Write-Host -Object $_.ScriptStackTrace
        ____ExitOne
    }
}