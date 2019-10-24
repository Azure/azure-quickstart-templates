<#
.Synopsis
    Ensures the apiVersions are recent.
.Description
    Ensures the apiVersions of any resources are recent and non-preview.
.Example
    Test-AzureRMTemplate -TemplatePath .\100-marketplace-sample\ -Test apiVersions-Should-Be-Recent
.Example
    .\apiVersions-Should-Be-Recent.test.ps1 -TemplateObject (
        Get-Content ..\..\..\..\100-marketplace-sample\azureDeploy.json | ConvertFrom-Json
    ) -AllAzureResources (
        Get-Content ..\..\cache\AllAzureResources.cache.json | ConvertFrom-Json
    )
      -TestDate (
          [datetime]::ParseExact("31/08/2019", "dd-mm-yy", $null)
    )
#>
param(
    # The resource in the main template
    [Parameter(Mandatory = $true, Position = 0)]
    [PSObject]
    $TemplateObject,

    # All potential resources in Azure (from cache)
    [Parameter(Mandatory = $true, Position = 2)]
    [PSObject]
    $AllAzureResources,

    # Number of days that the apiVersion must be less than
    [Parameter(Mandatory = $false, Position = 3)]
    [int32]
    $NumberOfDays = 730,

    # Test Run Date - date to use when doing comparisons, if not current date (used for unit testing against and old cache)
    [Parameter(Mandatory = $false, Position = 3)]
    [datetime]
    $TestDate = [DateTime]::Now

)


if (-not $TemplateObject.resources) {
    # If we don't have any resources
    # then it's probably a partial template, and there's no apiVersions to check anyway, 
    return # so return.
}

# First, find all of the API versions in the main template resources.
$allApiVersions = $TemplateObject.resources | 
Find-JsonContent -Key apiVersion -Value * -Like

foreach ($av in $allApiVersions) {
    # Then walk over each object containing an ApiVersion.
    Write-Host "Checking resource named `"$($av.name)`" with apiVersion `"$($av.apiVersion)`"" # TODO: Remove this
    if ($av.ApiVersion -isnot [string]) {
        # If the APIVersion is not a string
        # write an error 
        Write-Error "Api Versions must be strings" -TargetObject $av -ErrorId ApiVersion.Not.String
        continue # and continue.
    }

    # Next, resolve the full resource type
    $FullResourceTypes = 
    @(
        if ($av.ParentObject) {
            # by walking backwards over the parent resources 
            # (since the topmost resource will be the last item in the list)
            for ($i = $av.ParentObject.Count - 1; $i -ge 0; $i--) {
                if (-not $av.ParentObject[$i].type) { continue }
                $av.ParentObject[$i].type
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
        # If we couldn't, write an error
        
        Write-Error "Api versions must be a fixed date. $FullResourceType is not." -TargetObject $av -ErrorId ApiVersion.Not.Date
        continue # and move onto the next resource
    }
    $apiDate = [DateTime]::new($matches.Year, $matches.Month, $matches.Day) # now coerce the apiVersion into a DateTime

    

    # Now find all of the valid versions from this API
    $validApiVersions = # This is made a little tricky by the fact that some resources don't directly have an API version        
    @(for ($i = $FullResourceTypes.Count - 1; $i -ge 0; $i--) {
            # so we need to walk backwards thru the list of items
            $resourceTypeName = $FullResourceTypes[0..$i] -join '/' # construct the resource type name
            $apiVersionsOfType = $AllAzureResources.$resourceTypeName | # and see if there's an apiVersion.
            Select-Object -ExpandProperty apiVersions |
            Sort-Object -Descending

            if ($apiVersionsOfType) {
                # If there was,
                $apiVersionsOfType # set it and break the loop
                break
            }
        })

    #Create a string of recent or allowed apiVersions for display in the error message
    $recentApiVersions = ""
    foreach ($v in $validApiVersions) {

        $hasDate = $v -match "(?<Year>\d{4,4})-(?<Month>\d{2,2})-(?<Day>\d{2,2})"
        $vDate = [DateTime]::new($matches.Year, $matches.Month, $matches.Day) 

        #if the apiVersion is "recent" or the latest one add it to the list (note $validApiVersions is sorted)
        if ($($TestDate - $vDate).TotalDays -lt $NumberOfDays -or $v -eq $validApiVersions[0]) {
            $recentApiVersions += "      $v`n"
        }

    }

    $howOutOfDate = $validApiVersions.IndexOf($av.ApiVersion) # Find out how out of date we are.
    #Is the apiVersion even in the list?
    if ($howOutOfDate -eq -1 -and $validApiVersions) {
        # Removing the error for this now - this is happening with the latest versions and outdated manifests
        # We can assume that if the version is indeed invalid, deployment will fail
        # Write-Error "$fullResourceType is using an invalid apiVersion." -ErrorId ApiVersion.Not.Valid
        Write-Host "ApiVersion not found for: $fullResourceType and version $($av.apiVersion)" 
        Write-Host "Valid Api Versions found:`n$recentApiVersions"
    }

    if ($av.ApiVersion -like '*-*-*-*') {
        # If it's a preview or other special variant, e.g. 2016-01-01-preview
        $moreRecent = $validApiVersions[0..$howOutOfDate] # see if there's a more recent non-preview version. 
        if ($howOutOfDate -gt 0) {
            Write-Error "$FullResourceType uses a preview version ( $($av.apiVersion) ) and there are more recent versions available." -TargetObject $av -ErrorId ApiVersion.Preview.Not.Recent
            Write-Host "Valid Api Versions:`n$recentApiVersions"
        }        
    }
    # Finally, check how long it's been since the ApiVersion's date
    $timeSinceApi = $TestDate - $apiDate
    if (($timeSinceApi.TotalDays -gt $NumberOfDays) -and ($howOutOfDate -gt 0)) {
        # If it's older than two years, and there's nothing more recent
        Write-Error "Api versions must be the latest or under $($NumberOfDays / 365) years old ($NumberOfDays days) - API version $($av.ApiVersion) of $FullResourceType is $([Math]::Floor($timeSinceApi.TotalDays)) days old" -ErrorId ApiVersion.OutOfDate
        Write-Host "Valid Api Versions:`n$recentApiVersions"
    }
}
