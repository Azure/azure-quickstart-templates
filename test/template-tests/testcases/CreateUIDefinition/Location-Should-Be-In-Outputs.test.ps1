param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

<<<<<<< HEAD
# First, check that CreateUIDefinition has an outputs
if (-not $CreateUIDefinitionObject.parameters.outputs) {
    # (if it didn't, throw an error)
    throw "Outputs is missing from CreateUIDefinition"
=======
Write-Host "Here"
$CreateUIDefinitionObject.parameters.outputs | Out-String

if (-not $CreateUIDefinitionObject.parameters.outputs.location) {
    throw "Location is missing from outputs"
>>>>>>> d5babbc5995dacdb1c1f572491bdef4c18c35806
}

# Then, check that the location property exists in outputs
if (-not $CreateUIDefinitionObject.parameters.outputs.location) { 
    # (if it didn't, throw an error).
    throw "Location is missing from outputs"
}

<<<<<<< HEAD
# Last, make sure that the location's trimmed value is [location()]
if ("$($CreateUIDefinitionObject.outputs.location)".Trim() -ne '[location()]') {
    # (if it wasn't, throw an error)
=======
if ("$($CreateUIDefinitionObject.parameters.outputs.location)".Trim() -ne '[location()]') {
>>>>>>> d5babbc5995dacdb1c1f572491bdef4c18c35806
    throw "CreateUIDefinition.outputs.location must be [location()]"
}