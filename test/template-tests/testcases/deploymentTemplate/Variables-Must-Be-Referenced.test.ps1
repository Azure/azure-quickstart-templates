param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject,

[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateText
)


# TODO: Need to properly check for variable copy, see: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-multiple#variable-iteration

foreach ($variable in $TemplateObject.variables.psobject.properties) {

    # TODO: if the variable name is "copy": we need to loop through the array and pull each var and check individually

    if ($TemplateText -notmatch "\[.*?variables\s*\(\s*'$($Variable.Name)'\s*\)") {
            Write-Error -Message "Unreferenced variable: $($Variable.Name)" -ErrorId Variables.Must.Be.Referenced -TargetObject $variable
    }
}
 



