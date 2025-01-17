param(
    [String] $StrParam,
    [Int] $IntParam,
    [Boolean] $BoolParam
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host "-- Received params: StrParam=$StrParam, IntParam=$IntParam, BoolParam=$BoolParam"
$global:TestResults = @{
    StrParam  = $StrParam
    IntParam  = $IntParam
    BoolParam = $BoolParam
    PSScriptRoot = $PSScriptRoot
}

if ((Test-Path variable:global:TestShouldThrow) -and $global:TestShouldThrow) {
    throw "Test should throw"
}

if ((Test-Path variable:global:TestShouldExitWithNonZeroExitCode) -and ($global:TestShouldExitWithNonZeroExitCode -ne 0)) {
    cmd.exe /c dir 'Y:\path\does\not\exist'
}
