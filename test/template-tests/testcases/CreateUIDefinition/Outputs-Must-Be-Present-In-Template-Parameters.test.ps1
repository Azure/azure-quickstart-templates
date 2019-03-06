param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true,Position=1)]
[PSObject]
$TemplateObject
)


if (-not $CreateUIDefinitionObject.parameters.outputs) {
    throw "CreateUIDefinition is missing the .parameters.outputs property"
}


foreach ($output in $parameterInfo.outputs.psobject.properties) {
    $outputName = $output.Name
    if ($outputName -eq 'applicationresourcename') { 
        # subject to future removal, added by publishing process 
        continue 
    }     
    if (-not $TemplateObject.parameters.$outputName) {
        Write-Error "output $outputName does not exist in template.parameters"
    }
}



