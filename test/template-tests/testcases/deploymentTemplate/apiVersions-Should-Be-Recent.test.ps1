param(
# The resource in the main template
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$MainTemplateResources,

# All potential resources in Azure (from cache)
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$AllAzureResources
)

# First, find all of the API versions in the main template resources.
$allApiVersions = $MainTemplateResources | 
    Find-JsonContent -Key apiVersion -Value * -Like

foreach ($av in $allApiVersions) { # Then walk over each object containing an ApiVersion.

    if ($av.ApiVersion -isnot [string]) { # If the APIVersion is not a string
        # write an error 
        Write-Error "Api Versions must be strings" -TargetObject $av -ErrorId ApiVersion.Not.String
        continue # and continue.
    }

    # Next, resolve the full resource name
    $FullResourceTypes = 
        @(
        if ($av.ParentResources) { # by walking backwards over the parent resources 
            # (since the topmost resource will be the last item in the list)
            for ($i = $av.ParentResources.Count - 1; $i -ge 0; $i--) {
                $av.ParentResources[$i].type 
            }
        }
        $av.type # and adding this resource's type. 
        )

    # To get the full type name, join them all with a slash 
    $FullResourceType = $FullResourceTypes -join '/' 

    # Now, get the API version as a string
    $apiString = $av.ApiVersion 
    if ($apiString -like '*-preview') { # If it was a preview API, 
        # chop off the -preview from the text
        $apiString = $apiString.Substring(0, $apiString.Length - '-preview'.Length)
    }
    
    $apiDate = $av.ApiVersion -as [DateTime] # now coerce the apiVersion into a DateTime
    if (-not $apiDate) {
        # If this failed, write an error.
        Write-Error "Api versions must be a fixed date. $FullResourceType is not." -TargetObject $av -ErrorId ApiVersion.Not.Date
        continue
    }
    

    # Now find all of the valid versions from this API
    $validApiVersions = $AllAzureResources.$FullResourceType | 
        Select-Object -ExpandProperty apiVersions 

    # If the actual string in the template was not in the list of APIs,
    if ($validApiVersions -notcontains $av.ApiVersion) {
        # write an error
        Write-Error "$FullResourceType has an invalid API version.  Valid API versions are: $validApiVersions" -TargetObject $av
        continue
    }
    
    if ($av.ApiVersion -like '*-preview') {
        $howRecent? = $validApiVersions.IndexOf($av.ApiVersion) 
        if ($howRecent?) {
            Write-Error "$FullResourceType uses a -preview version when there are $($howRecent?) more recent versions available" -TargetObject $av
        } 
    }
    # Finally, check how long it's been since the ApiVersion's date
    $timeSinceApi = [DateTime]::Now - $apiDate
    if ($timeSinceApi.TotalDays -gt 365) {  # If it's older than a year
        # write a warning        
        Write-Warning "Api versions should be under a year old ($($helperName) is $([Math]::Floor($timeSinceApi.TotalDays)) days old)" 
    }
}