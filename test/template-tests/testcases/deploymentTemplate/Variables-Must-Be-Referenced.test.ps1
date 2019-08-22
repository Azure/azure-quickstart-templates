param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject,

[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateText
)
foreach ($variable in $TemplateObject.variables.psobject.properties) {
    if ($TemplateText -notmatch "variables\(['`"]$($Variable.Name)['`"]\)") {
        Write-Error -Message "Unreferenced variable: $($Variable.Name)" `
            -ErrorId Parameters.Must.Be.Referenced -TargetObject $variable
    }
}
 



