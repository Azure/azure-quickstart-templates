param(
[Parameter(Mandatory=$true)]
[string]
$TemplateText
)

$emptyItems = @([Regex]::Matches($TemplateText, "\{\s{0,}\}")) + # Empty objects
              @([Regex]::Matches($TemplateText, "\[\s{0,}\]")) + # empty arrays
              @([Regex]::Matches($TemplateText, '"\s{0,}"')) # empty strings

$lineBreaks = [Regex]::Matches($TemplateText, "`n|$([Environment]::NewLine)")

$PropertiesThatCanBeEmpty = 'resources','outputs','variables','parameters','properties','defaultValue'

if ($emptyItems) {
    foreach ($emptyItem in $emptyItems) {
        $nearbyContext = [Regex]::new('"(?<PropertyName>[^"]{1,})"\s{0,}:', "RightToLeft").Match($TemplateText, $emptyItem.Index)
        if ($nearbyContext -and $nearbyContext.Success) {
            $emptyPropertyName = $nearbyContext.Groups["PropertyName"].Value
            if ($PropertiesThatCanBeEmpty -contains $emptyPropertyName) {
                continue
            }
        } 
        
        $lineNumber = @($lineBreaks | ? { $_.Index -lt $emptyItem.Index }).Count + 1
        Write-Error "Empty property found on line: $lineNumber" -TargetObject $emptyItem
    }
}