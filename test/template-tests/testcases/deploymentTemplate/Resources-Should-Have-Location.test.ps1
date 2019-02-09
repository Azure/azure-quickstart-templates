param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)
foreach ($resource in $templateObject.resources) {
    if ($resource.Location) {
        $location = "$($resource.location)".Trim()
        if ($location -notmatch '^\[.*\]$' -and $location -ne 'global') {
            Write-Error "Resource $($resource.Name) Location must be an expression or 'global'" -TargetObject $resource
        }
    }
}




