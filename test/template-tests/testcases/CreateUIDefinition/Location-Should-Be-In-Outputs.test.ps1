<#
.Synopsis
    Ensures that the .location field exists in .outputs.
.Description
    Ensures that the .location field exists in .outputs, and is [location()]
.Example
    Test-AzureRMTemplate -TemplatePath .\100-marketplace-sample -Test Location-Should-Be-In-Outputs
.Example
    .\Location-Should-Be-In-Outputs.test.ps1 ([PSCustomObject]@{BadInput=$true})
#>
param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)
<#{
    Bad: {},
    Good: {
        parameters: {
            outputs: {
                location:"[location()]"
            }
        }
    }                
}#>


if (-not $CreateUIDefinitionObject.parameters.outputs) { # If CreateUIDefinition has no outputs
    Write-Error "Outputs is missing from CreateUIDefinition" -ErrorId CreateUIDefinition.Missing.Outputs # error
    return # and return.
}
if (-not $CreateUIDefinitionObject.parameters.outputs.location) { # If outputs does not have a location    
    Write-Error "Location is missing from outputs" -ErrorId CreateUIDefinition.Missing.Outputs.Location # error
    return # and return.
}

if ("$($CreateUIDefinitionObject.parameters.outputs.location)".Trim() -ne '[location()]') { # Last, make sure that the location's trimmed value is [location()].
    Write-Error "CreateUIDefinition.outputs.location must be [location()]" -ErrorId CreateUIDefinition.Incorrect.Outputs.Location -TargetObject $CreateUIDefinitionObject.parameters.outputs.location
}