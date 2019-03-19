param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

Write-Host "Here"
$CreateUIDefinitionObject.parameters.outputs | Out-String

if (-not $CreateUIDefinitionObject.parameters.outputs.location) {
    throw "Location is missing from outputs"
}


if ("$($CreateUIDefinitionObject.parameters.outputs.location)".Trim() -ne '[location()]') {
    throw "CreateUIDefinition.outputs.location must be [location()]"
}



