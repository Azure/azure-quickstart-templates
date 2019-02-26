param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

$shouldHaveTooltips = $CreateUIDefinitionObject  | 
    Find-AzureRMTemplate -Key type -Value Microsoft.* -Like
    
foreach ($shouldHave in $shouldHaveTooltips) {
    if (-not "$($shouldHave.tooltip)".Trim()) {
        Write-Error "Element missing tooltip: $($shouldHave.Name)" -TargetObject $shouldHave
    }
} 
