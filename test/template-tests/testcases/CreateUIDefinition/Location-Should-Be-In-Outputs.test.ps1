param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

if (-not $CreateUIDefinitionObject.outputs.location) {
    throw "Location is missing from outputs"
}


if ("$($CreateUIDefinitionObject.outputs.location)".Trim() -ne '[location()]') {
    throw "CreateUIDefinition.outputs.location must be [location()]"
}



