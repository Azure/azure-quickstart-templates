param(
    $Variable,
    $Value,
    $PrintValue = "true"
)
write-host $(if ($PrintValue -eq "true") { "Setting variable $Variable with value $Value" } else { "Setting variable $Variable" })
[Environment]::SetEnvironmentVariable("$Variable", "$Value", "Machine")
write-host $(if ($PrintValue -eq "true") { "Setting variable $Variable with value $Value complete" } else { "Setting variable $Variable complete" })