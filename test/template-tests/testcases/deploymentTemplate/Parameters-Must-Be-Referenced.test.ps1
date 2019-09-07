param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject,

[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateText
)

<#
- begins with "[
- any nymber of chars
- 0 or more whitespace
- parameters
- 0 or more whitespace
- (
- 0 or more whitespace
- '

An expression could be: "[ concat ( parameters ( 'test' ), ...)]"

#>

foreach ($parameter in $TemplateObject.parameters.psobject.properties) {
    if ($TemplateText -notmatch "\[.*?parameters\s*\(\s*'$($Parameter.Name)'\s*\)") {
        Write-Error -Message "Unreferenced parameter: $($Parameter.Name)" `
            -ErrorId Parameters.Must.Be.Referenced -TargetObject $parameter
    }
}
 



