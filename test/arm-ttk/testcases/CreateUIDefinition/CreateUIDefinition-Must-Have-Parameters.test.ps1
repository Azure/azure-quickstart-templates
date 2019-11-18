param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

if (-not $CreateUIDefinitionObject.parameters) {
    Write-Error "CreateUIDefinition is missing a parameters property"
}
