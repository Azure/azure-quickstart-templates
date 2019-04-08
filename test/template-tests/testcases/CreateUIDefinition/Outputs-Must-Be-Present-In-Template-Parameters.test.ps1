param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true,Position=1)]
[PSObject]
$TemplateObject
)

# First, make sure CreateUIDefinition has outputs
if (-not $CreateUIDefinitionObject.parameters.outputs) {
    # ( throw an error if it doesn't)
    throw "CreateUIDefinition is missing the .parameters.outputs property"
}


foreach ($output in $parameterInfo.outputs.psobject.properties) { # Then walk thru each output
    $outputName = $output.Name
    if ($outputName -eq 'applicationresourcename') { # If the output was 'applicationresourcename', 
        # we don't care  (this is added by publishing process and subject to future removal).
        continue 
    }
    # If the output name was not declared in the TemplateObject,      
    if (-not $TemplateObject.parameters.$outputName) {
        # write an error
        Write-Error "output $outputName does not exist in template.parameters"
    }
}



