param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$CreateUIDefinitionObject
)

# Find all Microsoft controls in CreateUIDefinition
$shouldHaveTooltips = $CreateUIDefinitionObject  | 
    Find-JsonContent -Key type -Value Microsoft.* -Like
    
foreach ($shouldHave in $shouldHaveTooltips) { # then loop through each control
    if (-not "$($shouldHave.tooltip)".Trim()) { # If there was no tool tip property, or the tooltip was only whitespace
        # write an error.
        Write-Error "Element missing tooltip: $($shouldHave.Name)" -TargetObject $shouldHave
    }
} 
