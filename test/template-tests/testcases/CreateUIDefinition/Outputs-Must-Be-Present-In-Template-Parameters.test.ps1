<#
.Synopsis
    Ensures that .outputs are present in the .parameters of CreateUIDefinition.json
.Description
    Ensures that .outputs are present in the .parameters of CreateUIDefinition.json, and that those parameters exist on the template object
.Example
    Test-AzureRMTemplate .\100-marketplace-sample -Test Outputs-Must-Be-Present-In-Template-Parameters
.Example
    .\Outputs-Must-Be-Present-In-Template-Parameters.test.ps1 -CreateUIDefinitionObject @([PSCustomObject]@{badinput=$true}) -TemplateObject ([PSCustomObject]@{})
#>
param(
# The CreateUIDefinition Object (the contents of CreateUIDefinition.json, converted from JSON)
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject,

# The Template Object (the contents of azureDeploy.json, converted from JSON)
[Parameter(Mandatory=$true,Position=1)]
[PSObject]
$TemplateObject
)
<#{
    good: {
        CreateUIDefinitionObject: {
            parameters: {
                outputs: {
                    testOutput: {}
                }
            }
        },
        TemplateObject: {
            parameters: {
                outputs: {
                    testOutput: {}
                }
            }
        }
    }
}#>

# First, make sure CreateUIDefinition has outputs
if (-not $CreateUIDefinitionObject.parameters.outputs) {
    Write-Error "CreateUIDefinition is missing the .parameters.outputs property" -ErrorId CreateUIDefinition.Missing.Outputs     # ( write an error if it doesn't)
}

foreach ($output in $parameterInfo.outputs.psobject.properties) { # Then walk thru each output
    $outputName = $output.Name
    if ($outputName -eq 'applicationresourcename' -or `
        $outputName -eq 'jitaccesspolicy' -or `
        $outputName -eq 'managedresourcegroupid') { # If the output was one of the outputs used for Managed Apps and only found in the generated template, skip the test
            continue 
    }
    # If the output name was not declared in the TemplateObject,      
    if (-not $TemplateObject.parameters.$outputName) {
        # write an error
        Write-Error "output $outputName does not exist in template.parameters" -ErrorId CreateUIDefinition.Output.Missing.From.MainTemplate -TargetObject $parameterInfo.outputs
    }
}
