<#
.Synopsis
    Ensures that there is no function used for a default parameter in the resourceId function (e.g. resourceGroup().namd, subscription().subscriptionId).
.Description
    Ensures that there is no function used for a default parameter in the resourceId function (e.g. resourceGroup().namd, subscription().subscriptionId).
.Example
    Test-AzTemplate -TemplatePath .\100-marketplace-sample\ -Test ResourceId-should-not-contain-resourcegroup-function
.Example
    .\ResourceIds-should-not-contain.test.ps1 -TemplateText (Get-Content -path ..\..\..\unit-tests\ResourceIds-should-not-contain.json -Raw)
    
#>
param(
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateText
)

# Check for any functions as parameters - PowerShell handles empty differently in objects so check the JSON source (i.e. text)
$items = @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}resourceId\s{0,}\(\s{0,}resourceGroup\(")) +            # resourceId(resourceGroup(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}resourceId\s{0,}\(\s{0,}subscription\(")) +             # resourceId(subscription(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}resourceId\s{0,}\(\s{0,}concat\s{0,}\(")) +             # resourceId(concat(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}tenantResourceId\s{0,}\(\s{0,}concat\s{0,}\(")) +       # tenantResourceId(concat(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}extensionResourceId\s{0,}\(\s{0,}concat\s{0,}\(")) +    # extensionResourceId(concat(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}subscriptionResourceId\s{0,}\(\s{0,}subscription\(")) + # subscriptionResourceId(subscription(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}subscriptionResourceId\s{0,}\(\s{0,}concat\s{0,}\(")) + # subscriptionResourceId(concat(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}reference\s{0,}\(\s{0,}concat\s{0,}\(")) +              # reference(concat(
         @([Regex]::Matches($TemplateText, "\s{0,}\[\s{0,}list\w{1,}\s{0,}\(\s{0,}concat\s{0,}\("))               # list*(concat(
       
$lineBreaks = [Regex]::Matches($TemplateText, "`n|$([Environment]::NewLine)")

# this just gets the line number and property name for the error message
if ($items) {
    $sortedItems = @()
    foreach ($item in $items) {
        $nearbyContext = [Regex]::new('"(?<PropertyName>[^"]{1,})"\s{0,}:', "RightToLeft").Match($TemplateText, $item.Index)
        if ($nearbyContext -and $nearbyContext.Success) {
            $PropertyName = $nearbyContext.Groups["PropertyName"].Value
            $lineNumber = @($lineBreaks | ? { $_.Index -lt $item.Index }).Count + 1
            $obj = New-Object -TypeName psobject -Property @{item=$item;lineNumber=$lineNumber;PropertyName=$PropertyName}
            $sortedItems += $obj
        } 
    }
    #sort the error output by line number
    $sortedItems = $sortedItems | Sort-Object -Property lineNumber
    foreach($item in $sortedItems){
        Write-Error "Using `"$($item.item)`" is not allowed - found on line: $($item.lineNumber) for property: $($item.PropertyName)" `
            -TargetObject $item -ErrorId ResourceId.Should.Not.Contain.Function

    }
}