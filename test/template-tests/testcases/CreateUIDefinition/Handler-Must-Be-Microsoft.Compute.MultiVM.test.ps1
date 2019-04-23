param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

# First, check that CreateUIDefintion has a handler property
if (-not $CreateUIDefinitionObject.handler) {
    # (if it didn't, throw an error)
    throw "CreateUIDefinition is missing handler property"
}

# Next, make sure CreateUIDefinition's handler is 'Microsoft.Compute.MultiVM' (case sensitive)
if ($CreateUIDefinitionObject.handler -cne 'Microsoft.Compute.MultiVm') {
    # (if it wasn't, throw an error)
    throw "The handler for CreateUIDefinition must be Microsoft.Compute.MultiVm"
}