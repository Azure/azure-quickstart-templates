param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true)]
[Collections.IDictionary]
$MainTemplateParameters
)

$sizeSelectors = $CreateUIDefinitionObject | 
    Find-AzureRMTemplate -Key type -Value Microsoft.Compute.SizeSelector


foreach ($selector in $sizeSelectors) {
    $MainTemplateParam = $MainTemplateParameters[$selector.Name]

    if (-not $MainTemplateParam) {
        Write-Error "VM Size selector $($selector.Name) is missing from main template parameters "-TargetObject $selector
        continue
    }

    if ($MainTemplateParam.defaultValue) {
        if ($selector.constraints.allowedsizes -and $selector.constraints.allowedsizes -notcontains $MainTemplateParam.defaultValue) {
            Write-Error "VM Size selector $($selector.Name) does not allow for the default value $($MainTemplateParam.defaultValue) used in the main template" 
        }
    }
}