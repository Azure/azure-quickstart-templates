param(
# The resource in the main template
[Parameter(Mandatory=$true,Position=0)]
[PSObject]
$TemplateObject,

# All potential resources in Azure (from cache)
[Parameter(Mandatory=$true,Position=2)]
[PSObject]
$AllAzureResources
)

# First, find all of the API versions in the main template resources.
$allApiVersions = $TemplateObject.resources | 
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
    $hasDate = $apiString -match "(?<Year>\d{4,4})-(?<Month>\d{2,2})-(?<Day>\d{2,2})"
    
    
    
    if (-not $hasDate) {
        # If this failed, write an error.
        Write-Error "Api versions must be a fixed date. $FullResourceType is not." -TargetObject $av -ErrorId ApiVersion.Not.Date
        continue
    }
    $apiDate = [DateTime]::new($matches.Year, $matches.Month, $matches.Day) # now coerce the apiVersion into a DateTime

    

    # Now find all of the valid versions from this API
    $validApiVersions = # This is made a little tricky by the fact that some resources don't directly have an API version        
        @(for ($i = $FullResourceTypes.Count - 1; $i -ge 0; $i--) { # so we need to walk backwards thru the list of items
            $resourceTypeName = $FullResourceTypes[0..$i] -join '/' # construct the resource type name
            $apiVersionsOfType = $AllAzureResources.$resourceTypeName | # and see if there's an apiVersion.
                Select-Object -ExpandProperty apiVersions |
                Sort-Object -Descending

            if ($apiVersionsOfType) { # If there was,
                $apiVersionsOfType # set it and break the loop
                break
            }
        })

    
    if ($av.ApiVersion -like '*-*-*-*') {
        #! Determine the index without respect to preview versions
        $howRecent? = $validApiVersions.IndexOf($av.ApiVersion) 
        if ($howRecent?) {
            Write-Error "$FullResourceType uses a preview version ( $($av.apiVersion) ) when there are $($howRecent?) more recent versions available" -TargetObject $av
        } 
    }
    # Finally, check how long it's been since the ApiVersion's date
    $timeSinceApi = [DateTime]::Now - $apiDate
    if ($timeSinceApi.TotalDays -gt 730) {  # If it's older than a year
        # write a warning        
        Write-Error "Api versions should be under 2 years old (730 days) - ($FullResourceType is $([Math]::Floor($timeSinceApi.TotalDays)) days old)" 
    }
}