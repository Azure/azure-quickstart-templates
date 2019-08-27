param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

if (-not $CreateUIDefinitionObject.'$Schema') {
    throw "CreateUIDefinition is missing a `$schema property"
}

if ($CreateUIDefinitionObject.'$schema' -cne 'https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#') {
    throw "CreateUIDefintion has an incorrect schema.  Schema should be https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#, and is '$($CreateUIDefinitionObject.'$schema')'"
}

if (-not $CreateUIDefinitionObject.version) {
    throw "CreateUIDefinition is missing a version"
}

# Remove any preview chunk and cast the remaining portion as a version (make clearer)
$schemaVersion = $CreateUIDefinitionObject.'$Schema' -split '/' -ne '' |
    ? { 
        $str = $_
        $firstPart, $rest = $_ -split '-'
        $firstPart -as [Version] -gt '0.0' 
    } |
    Select-Object -First 1

if ($CreateUIDefinitionObject.version -ne $schemaVersion) {
    throw "CreateUIDefinition version ($($CreateUIDefinitionObject.version)) is different from schema version ($schemaVersion)"
}