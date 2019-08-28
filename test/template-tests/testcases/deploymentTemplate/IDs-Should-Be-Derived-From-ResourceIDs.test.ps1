<#
.Synopsis
    Ensures that all IDs use the resourceID() function.
.Description
    Ensures that all IDs use the resourceID() function, or resolve to parameters or variables that use the ResourceID() function.
.Example
    Test-AzureRMTemplate -TemplatePath .\100-marketplace-sample\ -Test IDs-Should-Be-Derived-From-ResourceIDs
.Example
    .\IDs-Should-Be-Derived-From-ResourceIDs.test.ps1 -TemplateObject (Get-Content ..\..\..\..\100-marketplace-sample\azureDeploy.json | ConvertFrom-Json) 
#>
param(
# The template object (the contents of azureDeploy.json, converted from JSON)
[Parameter(Mandatory=$true,Position=0)]
$TemplateObject)

# First, find all objects with an ID property in the MainTemplate.
$ids = $TemplateObject  | Find-JsonContent -Key id -Value * -Like

foreach ($id in $ids) { # Then loop over each object with an ID
    $myId = "$($id.id)".Trim() # Grab the actual ID,
    $expandedId = Expand-AzureRMTemplate -Expression $myId -InputObject $TemplateObject # then expand it.
    # Check that it uses the ResourceID or a param or var - can remove variables once Expand-Template does full eval of nested vars
    if ($expandedId -notmatch '\[resourceId\(' -and `
        $expandedId -notmatch '\[parameters\(' -and `
        $expandedId -notmatch '\[variables\(') { 
        # if it didn't, write an error.
        Write-Error "resourceId() must be used for resourceId properties: $($id.id)" -TargetObject $id
    }
}
