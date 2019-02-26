param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$MainTemplateObject
)

$allApiVersions = $MainTemplateObject | 
    Find-AzureRMTemplate -Key apiVersion -Value * -Like

foreach ($av in $allApiVersions) {
    if ($av.ApiVersion -isnot [string]) {
        Write-Error "Api Versions must be strings" -TargetObject $av -ErrorId ApiVersion.Not.String
        continue
    }
    $helperName = if ($av.type) {
        $av.type
    } elseif ($av.name) {
        $av.name
    } else {
        ''
    }

    $apiDate = $av.ApiVersion -as [DateTime]
    if (-not $apiDate) {
        Write-Error "Api versions must be a fixed date: ($helperName is not)" -TargetObject $av -ErrorId ApiVersion.Not.Date
        continue
    }
    

    $timeSinceApi = [DateTime]::Now - $apiDate
    if ($timeSinceApi.TotalDays -gt 365) {
        Write-Error "Api versions should be under a year old ($($helperName) is $([Math]::Floor($timeSinceApi.TotalDays)) days old)" -TargetObject $av -ErrorId ApiVersion.Outdated
    }
}
