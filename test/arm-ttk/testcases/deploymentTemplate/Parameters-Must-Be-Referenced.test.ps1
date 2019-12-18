param(
    [Parameter(Mandatory = $true, Position = 0)]
    [PSObject]
    $TemplateObject,

    [Parameter(Mandatory = $true, Position = 0)]
    [PSObject]
    $TemplateText
)

<# REGEX
- start with "
- 0 or more whitespace
- open bracket for expression [
- any number of chars, the reference can be anywhere in the expression
- parameters
- 0 or more whitespace
- open paren (
- 0 or more whitespace
- opening '

An expression could be: "[ concat ( parameters ( 'test' ), ...)]"

#>

foreach ($parameter in $TemplateObject.parameters.psobject.properties) {

    if (!($parameter.name.startswith('__'))) {
        
        if ($TemplateText -notmatch "(?s)`"\s{0,}\[.*?parameters\s{0,}\(\s{0,}'$($Parameter.Name)'") {
            Write-Error -Message "Unreferenced parameter: $($Parameter.Name)" -ErrorId Parameters.Must.Be.Referenced -TargetObject $parameter
        }

    }
}
 



