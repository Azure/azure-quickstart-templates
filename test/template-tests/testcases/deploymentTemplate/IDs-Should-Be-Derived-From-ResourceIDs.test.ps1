param(
[Parameter(Mandatory=$true,Position=0)]
$MainTemplateObject
)

# First, find all objects with an ID property in the MainTemplate.
$ids = $MainTemplateObject  | Find-JsonContent -Key id -Value * -Like 

foreach ($id in $ids) { # Then loop over each object with an ID
    $myId = "$($id.id)".Trim() # Grab the actual ID,
    $expandedId = Expand-AzureRMTemplate -Expression $myId -InputObject $MainTemplateObject
    if ($myId -notmatch '\[resourceId\(') { # check that it uses the ResourceID function
        # if it didn't, write an error.
        Write-Error "resourceId() must be used for resourceId properties: $($id.id)" -TargetObject $id 
    }
}