param(
    [Parameter(Mandatory = $true, Position = 0)]
    [PSObject]
    $CreateUIDefinitionObject
)

# Find all Microsoft controls in CreateUIDefinition
$shouldHaveTooltips = $CreateUIDefinitionObject | 
    Find-JsonContent -Key type -Value Microsoft.* -Like
   
$noToolTipControls = "Microsoft.Common.InfoBox", "Microsoft.Common.Section", "Microsoft.Common.TextBlock"

foreach ($shouldHave in $shouldHaveTooltips) {
    # then loop through each control
    if ($noToolTipControls -notcontains $shouldHave.type) { # skip controls that don't support tooltips
        if (-not "$($shouldHave.tooltip)".Trim()) {
            # If there was no tool tip property, or the tooltip was only whitespace
            # write an error.
            Write-Error "Element missing tooltip: $($shouldHave.Name)" -TargetObject $shouldHave
        }
    }
} 
