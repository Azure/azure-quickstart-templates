param(
[Parameter(Mandatory=$false,Position=0)] #not mandatory for case of an empty resource array
[PSObject]
$MainTemplateResources
)
foreach ($mtr in $MainTemplateResources) {
    foreach ($resource in @(@($mtr) + $mtr.ParentResources)) { 
        if ($resource.Location) {
            $location = "$($resource.location)".Trim()
            if ($location -notmatch '^\[.*\]$' -and $location -ne 'global') {
                Write-Error "Resource $($resource.Name) Location must be an expression or 'global'" -TargetObject $resource
            }
        }
    }
}
