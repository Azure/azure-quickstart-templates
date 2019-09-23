param(
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject
)

if (-not $TemplateObject.psobject.properties.item('parameters')) {
    Write-Error -Message "Parameters property must exist in the template"
} 