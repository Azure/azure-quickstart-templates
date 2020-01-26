param(
    [Parameter(Mandatory = $true, Position = 0)]
    [PSObject]
    $TemplateObject,

    [Parameter(Mandatory = $true, Position = 1)]
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

An expression could be: "[ concat ( variables ( 'test' ), ...)]"

#>

# TODO: Need to properly check for variable copy, see: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-multiple#variable-iteration

foreach ($variable in $TemplateObject.variables.psobject.properties) {

    # TODO: if the variable name is "copy": we need to loop through the array and pull each var and check individually
    if (!($variable.name.startswith('__')) -and ($variable.name -ne 'copy') ) {

        if ($TemplateText -notmatch "(?s)`"\s{0,}\[.*?variables\s{0,}\(\s{0,}'$($Variable.Name)'") {
            Write-Error -Message "Unreferenced variable: $($Variable.Name)" -ErrorId Variables.Must.Be.Referenced -TargetObject $variable
        }
        
    }
}
 



