param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

if (-not $CreateUIDefinitionObject.'$Schema') {
    Write-Error -Message "CreateUIDefinition is missing a `$schema property" -ErrorId CreateUIDef.Must.Have.Schema
}

if ($CreateUIDefinitionObject.'$schema' -cne 'https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#') {
    Write-Error -Message "CreateUIDefintion has an incorrect schema.  Schema must be https://schema.management.azure.com/schemas/0.1.2-preview/CreateUIDefinition.MultiVm.json#, and is '$($CreateUIDefinitionObject.'$schema')'" -ErrorId CreateUIDef.Incorrect.Schema
}

if (-not $CreateUIDefinitionObject.version) {
    Write-Error -Message "CreateUIDefinition is missing a version" -ErrorId CreateUIDef.Must.Have.Version
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
    Write-Error -Message "CreateUIDefinition version ($($CreateUIDefinitionObject.version)) is different from schema version ($schemaVersion)" -ErrorId CreateUIDef.Version.Mismatch
}