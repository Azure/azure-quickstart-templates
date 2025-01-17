param(
    $Variable,
    $Value,
    $PrintValue = "true"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Write-Host $(if ($PrintValue -eq "true") { "Setting variable $Variable with value $Value" } else { "Setting variable $Variable" })
[Environment]::SetEnvironmentVariable("$Variable", "$Value", "Machine")
