param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

if (-not $CreateUIDefinitionObject.parameters) {
    throw "CreateUIDefinition is missing a parameters property"
}

if (-not $CreateUIDefinitionObject.parameters.basics) {
    Write-Error "CreateUIDefinition is missing .parameters.basics"     
}


