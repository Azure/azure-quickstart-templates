<#
.Synopsis
    Ensures that there is no function used for a default parameter in the resourceId function (e.g. resourceGroup().namd, subscription().subscriptionId).
.Description
    Ensures that there is no function used for a default parameter in the resourceId function (e.g. resourceGroup().namd, subscription().subscriptionId).
.Example
    Test-AzureRMTemplate -TemplatePath .\100-marketplace-sample\ -Test ResourceId-should-not-contain-resourcegroup-function
.Example
    .\ResourceId-should-not-contain-resourcegroup-function.test.ps1 -TemplateObject (Get-Content ..\..\..\..\100-marketplace-sample\azureDeploy.json | ConvertFrom-Json)
#>
param(
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateText
)

# Check for any functions as parameters - PowerShell handles empty differently in objects so check the JSON source (i.e. text)
$items = @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}resourceId\s{0,}\(\s{0,}resourceGroup\(")) + # resourceId(resourceGroup(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}resourceId\s{0,}\(\s{0,}subscription\("))    # resourceId(subscription(

$lineBreaks = [Regex]::Matches($TemplateText, "`n|$([Environment]::NewLine)")

# this just gets the line number and property name for the error message
if ($items) {
    foreach ($item in $items) {
        $nearbyContext = [Regex]::new('"(?<PropertyName>[^"]{1,})"\s{0,}:', "RightToLeft").Match($TemplateText, $item.Index)
        if ($nearbyContext -and $nearbyContext.Success) {
            $PropertyName = $nearbyContext.Groups["PropertyName"].Value
            $lineNumber = @($lineBreaks | ? { $_.Index -lt $item.Index }).Count + 1
            Write-Error "Using `"$item`" is not allowed - found on line: $lineNumber for property: $PropertyName" `
                -TargetObject $item -ErrorId ResourceId.Should.Not.Contain.Default.Function
        } 
    }
}