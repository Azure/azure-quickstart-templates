function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,

        [Parameter()]
        [System.Boolean]
        $AutoCreateNewManagedProperties,

        [Parameter()]
        [System.Boolean]
        $DiscoverNewProperties,

        [Parameter()]
        [System.Boolean]
        $MapToContents,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Metadata Category Setting for '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments @($PSBoundParameters) `
                                  -ScriptBlock {
        $params = $args[0]

        $ssa = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
        if ($null -eq $ssa)
        {
            throw("The specified Search Service Application $($params.ServiceAppName) is  `
                   invalid. Please make sure you specify the name of an existing service application.")
        }
        $category = Get-SPEnterpriseSearchMetadataCategory -SearchApplication $ssa | `
                                    Where-Object{$_.Name -eq $params.Name}
        if ($null -eq $category)
        {
            return @{
                Name = $params.Name
                ServiceAppName = $params.ServiceAppName
                AutoCreateNewManagedProperties = $null
                DiscoverNewProperties = $null
                MapToContents = $null
                Ensure = "Absent"
            }
        }
        else
        {
            $results = @{
                Name = $params.Name
                ServiceAppName = $params.ServiceAppName
                AutoCreateNewManagedProperties = $category.AutoCreateNewManagedProperties
                DiscoverNewProperties = $category.DiscoverNewProperties
                MapToContents = $category.MapToContents
                Ensure = "Present"
            }
            return $results
        }
    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,

        [Parameter()]
        [System.Boolean]
        $AutoCreateNewManagedProperties,

        [Parameter()]
        [System.Boolean]
        $DiscoverNewProperties,

        [Parameter()]
        [System.Boolean]
        $MapToContents,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Metadata Category Setting for '$Name'"

    # Validate that the specified crawled properties are all valid and existing
    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters) `
                        -ScriptBlock {
        $params = $args[0]

        $ssa = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
        if ($null -eq $ssa)
        {
            throw("The specified Search Service Application $($params.ServiceAppName) is  `
                   invalid. Please make sure you specify the name of an existing service application.")
        }

        # Set the specified properties on the Managed Property
        $category = Get-SPEnterpriseSearchMetadataCategory -Identity $params.Name `
                                                           -SearchApplication $params.ServiceAppName

        # The category exists and it shouldn't, delete it;
        if ($params.Ensure -eq "Absent" -and $null -ne $category)
        {
            # If the category we are trying to remove is not empty, throw an error
            if ($category.CrawledPropertyCount -gt 0)
            {
                throw "Cannot delete Metadata Category $($param.Name) because it contains " + `
                      "Crawled Properties. Please remove all associated Crawled Properties " + `
                      "before attempting to delete this category."
            }
            Remove-SPEnterpriseSearchMetadataCategory -Identity $params.Name `
                                                      -SearchApplication $params.ServiceAppName `
                                                      -Confirm:$false
        }

        # The category doesn't exist, but should
        if ($params.Ensure -eq "Present" -and $null -eq $category)
        {
            $category = New-SPEnterpriseSearchMetadataCategory -Name $params.Name `
                                                               -SearchApplication $params.ServiceAppName
        }
        Set-SPEnterpriseSearchMetadataCategory -Identity $params.Name `
                                               -SearchApplication $params.ServiceAppName `
                                               -AutoCreateNewManagedProperties $params.AutoCreateNewManagedProperties `
                                               -DiscoverNewProperties $params.DiscoverNewProperties `
                                               -MapToContents $params.MapToContents
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,

        [Parameter()]
        [System.Boolean]
        $AutoCreateNewManagedProperties,

        [Parameter()]
        [System.Boolean]
        $DiscoverNewProperties,

        [Parameter()]
        [System.Boolean]
        $MapToContents,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Metadata Category Setting for '$Name'"

    $PSBoundParameters.Ensure = $Ensure
    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Name",
                                                     "PropertyType",
                                                     "Ensure",
                                                     "AutoCreateNewManagedProperties",
                                                     "DiscoverNewProperties",
                                                     "MapToContents")
}

Export-ModuleMember -Function *-TargetResource
