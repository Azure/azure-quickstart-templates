param(
[Parameter(Mandatory=$true,Position=0)]
[string]$TemplateText,

[Parameter(Mandatory=$true,Position=1)]
[string]$TemplateObject,

[Parameter(Mandatory=$true,Position=1)]
[switch]$IsMainTemplate
)
$TemplateObjectCopy = $templateText | ConvertFrom-Json
$TemplateObjectCopy.parameters.psobject.properties.remove('location')
$TemplateWithoutLocationParameter = $TemplateObjectCopy | 
    ConvertTo-Json -Depth 10        

 
$locationParameter = $templateObject.parameters.location

if ($locationParameter -and 
    $locationParameter.defaultvalue -ne '[resourceGroup().location]' -and 
    $IsMainTemplate) {
    Write-Error "Location parameter must not be hardcoded.  The default value should be [resourceGroup().location]." -ErrorId Location.Parameter.Hardcoded -TargetObject $parameter
}

if ($TemplateWithoutLocationParameter -like '*resourceGroup().location*') {
    Write-Error "$TemplateFileName must use the location parameter, not resourceGroup().location (except when used as a default value)" -ErrorId Location.Parameter.Should.Be.Used -TargetObject $parameter
}