param(
[Parameter(Mandatory=$true,Position=0)]
[string]$TemplateText,

[Parameter(Mandatory=$true,Position=1)]
[PSObject]$TemplateObject,

[Parameter(Mandatory=$true,Position=1)]
[switch]$IsMainTemplate
)

# First, create a copy of the template object
$TemplateObjectCopy = $templateText | ConvertFrom-Json
# Then remove the location property
$TemplateObjectCopy.parameters.psobject.properties.remove('location')
# and turn it back into JSON.
$TemplateWithoutLocationParameter = $TemplateObjectCopy | 
    ConvertTo-Json -Depth 10        

# Now get the location parameter 
$locationParameter = $templateObject.parameters.location

# All location parameters must be of type "string" in the parameter declaration
if($locationParameter.type -ne "string"){
    Write-Error "The location parameter must be a 'string' type in the parameter delcaration `"$($locationParameter.type)`"" -ErrorId Location.Parameter.TypeMisMatch -TargetObject $parameter
}

# In mainTemplate:
# there must be a parameter named "location"
# if that parameter has a defaultValue, it must be the expression [resourceGroup().location] 
if ($IsMainTemplate){ 
    if($locationParameter.defaultValue -and "$($locationParameter.defaultvalue)".Trim() -ne '[resourceGroup().location]') {
    Write-Error "The defaultValue of the location parameter in the main template must not be a specific location. The default value must be [resourceGroup().location]. It is `"$($locationParameter.defaultValue)`"" -ErrorId Location.Parameter.Hardcoded -TargetObject $parameter
}
# In all other templates:
# if the parameter named "location" exists, it must not have a defaultValue property
# Note that Powershell will count an empty string (which should fail the test) as null if not explictly tested, so we check for it
}else {
    if($locationParameter.defaultValue -ne $null){ 
        Write-Error "The location parameter of nested templates must not have a defaultValue property. It is `"$($locationParameter.defaultValue)`"" -ErrorId Location.Parameter.DefaultValuePresent -TargetObject $parameter
    }   
}
# Now check that the rest of the template doesn't use [resourceGroup().location] 
if ($TemplateWithoutLocationParameter -like '*resourceGroup().location*') {
    # If it did, write an error
    Write-Error "$TemplateFileName must use the location parameter, not resourceGroup().location (except when used as a default value in the main template)" -ErrorId Location.Parameter.Should.Be.Used -TargetObject $parameter
}