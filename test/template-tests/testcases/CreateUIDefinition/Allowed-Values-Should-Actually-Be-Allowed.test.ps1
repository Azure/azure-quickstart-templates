param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true)]
[Collections.IDictionary]
$MainTemplateParameters
)

$allowedValues = $CreateUIDefinitionObject | 
    Find-AzureRMTemplate -Key allowedValues -Value * -Like

foreach ($av in $allowedValues) {
    $parent = $av.ParentObject[0]

    $MainTemplateParam = $MainTemplateParameters[$parent.Name]

    if (-not $MainTemplateParam) {
        Write-Error "CreateUIDefinition has parameter $($parent.Name), but it is missing from main template parameters "-TargetObject $parent
        continue
    }

    $reallyAllowedValues = @(foreach ($v in $av.allowedValues) {
        if ($v.value) {
            $v.value
        } else {
            $v
        }
    })

    if ($MainTemplateParam.defaultValue -and 
        $reallyAllowedValues -notcontains $MainTemplateParam.defaultValue) {
        Write-Error "CreateUIDefinition paremter $($parent.Name) does not allow for the default value $($MainTemplateParam.defaultValue) used in the main template"
   }
}
