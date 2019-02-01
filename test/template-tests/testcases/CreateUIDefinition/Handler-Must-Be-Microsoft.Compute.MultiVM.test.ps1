param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

if (-not $CreateUIDefinitionObject.handler) {
    throw "CreateUIDefinition is missing handler property"
}

if ($CreateUIDefinitionObject.handler -cne 'Microsoft.Compute.MultiVm') {
    throw "The handler for CreateUIDefinition must be Microsoft.Compute.MultiVm"
} 



