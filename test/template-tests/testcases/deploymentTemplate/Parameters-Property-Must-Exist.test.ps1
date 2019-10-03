param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)
# TODO: do we still need this test?  it's implied by checking for other parameters (e.g. location)
if (-not $TemplateObject.psobject.properties.item('parameters')) {
    Write-Error -Message "Parameters property must exist in the template"
} 