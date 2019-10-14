param(
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateText
)

# Check for any text to remove empty property values - PowerShell handles empty differently in objects so check the JSON source (i.e. text)
# Empty strings, arrays, objects and null property values are not allowed, they have specific meaning in a declarative model
$emptyItems = @([Regex]::Matches($TemplateText, "\{\s{0,}\}")) + # Empty objects
              @([Regex]::Matches($TemplateText, "\[\s{0,}\]")) + # empty arrays
              @([Regex]::Matches($TemplateText, '"\s{0,}"')) # empty strings

# TODO: This test will flag things like json('null') - that needs to be fixed before we add a check for null
# @([Regex]::Matches($TemplateText, 'null')) # null json property value

$lineBreaks = [Regex]::Matches($TemplateText, "`n|$([Environment]::NewLine)")

# Some properties can be empty for readability
$PropertiesThatCanBeEmpty = 'resources', 'outputs', 'variables', 'parameters', 'functions', 'properties', 'defaultValue'

if ($emptyItems) {
    foreach ($emptyItem in $emptyItems) {
        $nearbyContext = [Regex]::new('"(?<PropertyName>[^"]{1,})"\s{0,}:', "RightToLeft").Match($TemplateText, $emptyItem.Index)
        if ($nearbyContext -and $nearbyContext.Success) {
            $emptyPropertyName = $nearbyContext.Groups["PropertyName"].Value
            if ($PropertiesThatCanBeEmpty -contains $emptyPropertyName) {
                continue
            }
            $lineNumber = @($lineBreaks | ? { $_.Index -lt $emptyItem.Index }).Count + 1
            Write-Error "Empty property found on line: $lineNumber" -TargetObject $emptyItem
        } 
    }
}