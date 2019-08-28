param(
# The create UI Definition object
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

# First, check that CreateUIDefintion has a handler property
if (-not $CreateUIDefinitionObject.handler) {
    # (if it didn't, throw an error)
    Write-Error "CreateUIDefinition is missing handler property" -ErrorId CreateUIDefinition.Missing.Handler
}

# Next, make sure CreateUIDefinition's handler is 'Microsoft.Compute.MultiVM' (case sensitive)
if (($CreateUIDefinitionObject.handler -cne 'Microsoft.Compute.MultiVm') -and `
    ($CreateUIDefinitionObject.handler -cne 'Microsoft.Azure.CreateUIDef')) {
    # (if it wasn't, throw an error)
    Write-Error "The handler for CreateUIDefinition must be 'Microsoft.Compute.MultiVm' or 'Microsoft.Azure.CreateUIDef'" -ErrorId CreateUIDefinition.Incorrect.Handler
}