param(
    $Variable
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

write-host "Removing variable $Variable"
[Environment]::SetEnvironmentVariable("$Variable", $null, "Machine")
write-host "Removing variable $Variable complete"