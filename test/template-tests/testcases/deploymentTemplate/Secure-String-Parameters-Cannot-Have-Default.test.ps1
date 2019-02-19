param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)
foreach ($parameterProp in $templateObject.parameters.psobject.properties) {
    $parameter = $parameterProp.Value
    $name = $parameterProp.Name
    if ($parameter.Type -eq 'securestring' -and 
        $parameter.defaultValue) # Will return true when defaultvalue is not null or blank (blank values are OK). 
    {
        Write-Error -Message "Parameter $name is a SecureString, and must not have a default value." `
            -ErrorId SecureString.Must.Not.Have.Default -TargetObject $parameter
    }
}




