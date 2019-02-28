param(
[Parameter(Mandatory=$true)]
[PSObject]
$TemplateObject,

[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject
)

foreach ($parameter in $TemplateObject.parameters.psobject.properties) {
    $parameterName = $parameter.Name
    $parameterInfo = $parameter.Value
    $defaultValue = $parameterInfo.defaultValue
    if (-not $defaultValue) { # PowerShell -not will cover both null and blank strings
        if (-not $CreateUIDefinitionObject.outputs.$parameterName) {
            Write-Error "$parameterName does not have a default value, and is not defined in CreateUIDefinition.outuputs" -ErrorId Parameter.Without.Default.Missing.From.CreateUIDefinition -TargetObject $TemplateObject.parameters
            continue
        }
    }
}