param(
    [Parameter(Mandatory = $true, Position = 0)]
    [PSObject]
    $TemplateObject
)
foreach ($parameterProp in $templateObject.parameters.psobject.properties) {
    $parameter = $parameterProp.Value
    $name = $parameterProp.Name
    
    # If the parameter is a secureString type and has a defaultValue:
    if ($parameter.Type -eq 'securestring' -and $parameter.defaultValue) { 
        # the defaultValue must be an empty string "" or must be an expression that contains use the newGuid() function
        if ($parameter.defaultValue -ne "" -and $parameter.defaultValue -notlike '`[*newGuid(*]') {
            # Will return true when defaultvalue is not null or blank (blank values are OK). 
            Write-Error -Message "Parameter $name is a SecureString and must not have a default value unless it is an expression that contains the newGuid() function." `
                -ErrorId SecureString.Must.Not.Have.Default -TargetObject $parameter
        }
    }
}
