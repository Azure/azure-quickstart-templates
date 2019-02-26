param(
[Parameter(Mandatory=$true)]
[PSObject]
$CreateUIDefinitionObject,

[Parameter(Mandatory=$true)]
[Collections.IDictionary]
$MainTemplateParameters
)

$passwordBoxes = $CreateUIDefinitionObject | 
    Find-AzureRMTemplate -Key type -Value Microsoft.Common.PasswordBox
    
foreach ($pwb in $passwordBoxes) {
    $MainTemplateParam = $MainTemplateParameters[$selector.Name]

    if (-not $MainTemplateParam) {
        Write-Error "Password box $($pwb.Name) is missing from main template parameters "-TargetObject $pwb
        continue
    }

    if ($MainTemplateParam.type -ne 'SecureString') {
        Write-Error "Password boxes must be used for secure string parameters.  The Main template parameter $($pwb.Name) is a $($MainTemplateParam.type)" -TargetObject @($pwb, $MainTemplateParam)
    }
}