param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)
foreach ($parameter in $templateObject.parameters) {
    if ($parameter.Type -eq 'securestring' -and $parameter.defaultValue) {
        Write-Error -Message "Parameter $($parameter.Name) is a SecureString, and must not have a default value." `
            -ErrorId SecureString.Must.Not.Have.Default -TargetObject $parameter
    }
}




