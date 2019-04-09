param(
[Parameter(Mandatory=$true)]
[string]
$TemplateText
)

$emptyItems = @([Regex]::Matches($TemplateText, "\{\s{0,}\}")) + # Empty classes
     @([Regex]::Matches($TemplateText, "\[\s{0,}\]")) + # empty lists
     @([Regex]::Matches($TemplateText, '"\s{0,}"')) # empty strings

$lineBreaks = [Regex]::Matches($TemplateText, "`n|$([Environment]::NewLine)")

if ($emptyItems) {
    foreach ($emptyItem in $emptyItems) {
        $lineNumber = @($lineBreaks | ? { $_.Index -lt $emptyItem.Index }).Count + 1
        Write-Error "Blank content found on line $lineNumber" -TargetObject $emptyItem
    }
}
