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

        [Parameter(Mandatory = $true)]
        [ValidateSet("Binary","DateTime","Decimal","Double","Integer","Text","YesNo")]
        [System.String]
        $PropertyType,

        [Parameter()]
        [System.Boolean]
        $Searchable,

        [Parameter()]
        [System.Boolean]
        $Queryable,

        [Parameter()]
        [System.Boolean]
        $Retrievable,

        [Parameter()]
        [System.Boolean]
        $HasMultipleValues,

        [Parameter()]
        [System.Boolean]
        $Refinable,

        [Parameter()]
        [System.Boolean]
        $Sortable,

        [Parameter()]
        [System.Boolean]
        $SafeForAnonymous,

        [Parameter()]
        [System.String[]]
        $Aliases,

        [Parameter()]
        [System.Boolean]
        $TokenNormalization,

        [Parameter()]
        [System.Boolean]
        $NoWordBreaker,

        [Parameter()]
        [System.Boolean]
        $IncludeAllCrawledProperties,

        [Parameter()]
        [System.String[]]
        $CrawledProperties,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Managed Property Setting for '$Name'"

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
        $managedProperty = Get-SPEnterpriseSearchMetadataManagedProperty -SearchApplication $ssa | `
                                    Where-Object{$_.Name -eq $params.Name}
        if ($null -eq $managedProperty)
        {
            return @{
                Name = $params.Name
                ServiceAppName = $params.ServiceAppName
                PropertyType = $params.PropertyType
                Ensure = "Absent"
            }
        }
        else
        {
            $aliases = $managedProperty.GetAliases()

            $mappedCrawlProperties = $managedProperty.GetMappedCrawledProperties($false)
            $includeAllCrawlProperties = $true
            if ($mappedCrawlProperties)
            {
                $includeAllCrawlProperties = $false
            }
            $results = @{
                Name = $params.Name
                ServiceAppName = $params.ServiceAppName
                PropertyType = $managedProperty.ManagedType
                Searchable = $managedProperty.Searchable
                Queryable = $managedPRoperty.Queryable
                Retrievable = $managedProperty.Retrievable
                HasMultipleValues = $managedProperty.HasMultipleValues
                Refinable = $managedProperty.Refinable
                Sortable = $managedProperty.Sortable
                SafeForAnonymous = $managedProperty.SafeForAnonymous
                Aliases = $aliases
                TokenNormalization = $managedProperty.TokenNormalization
                NoWordBreaker = $managedProperty.NoWordBreaker
                IncludeAllCrawledProperties = $includeAllCrawlProperties
                Ensure = "Present"
            }

            if (!$includeAllCrawlProperties)
            {
                $crawledProperties = @()
                foreach ($mappedProperty in $mappedCrawlProperties)
                {
                    $crawledProperties += $mappedProperty.Name
                }
                $results.Add("CrawledProperties", $crawledProperties)
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

        [Parameter(Mandatory = $true)]
        [ValidateSet("Binary","DateTime","Decimal","Double","Integer","Text","YesNo")]
        [System.String]
        $PropertyType,

        [Parameter()]
        [System.Boolean]
        $Searchable,

        [Parameter()]
        [System.Boolean]
        $Queryable,

        [Parameter()]
        [System.Boolean]
        $Retrievable,

        [Parameter()]
        [System.Boolean]
        $HasMultipleValues,

        [Parameter()]
        [System.Boolean]
        $Refinable,

        [Parameter()]
        [System.Boolean]
        $Sortable,

        [Parameter()]
        [System.Boolean]
        $SafeForAnonymous,

        [Parameter()]
        [System.String[]]
        $Aliases,

        [Parameter()]
        [System.Boolean]
        $TokenNormalization,

        [Parameter()]
        [System.Boolean]
        $NoWordBreaker,

        [Parameter()]
        [System.Boolean]
        $IncludeAllCrawledProperties,

        [Parameter()]
        [System.String[]]
        $CrawledProperties,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Managed Property Setting for '$Name'"

    # Obtain information about the current state of the Managed property (if it exists)
    $CurrentValues = Get-TargetResource @PSBoundParameters

    # Validate that the specified crawled properties are all valid and existing
    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters, `
                                     $CurrentValues) `
                        -ScriptBlock {
        $params = $args[0]
        $CurrentValues = $args[1]

        #region Pre-Validation
        # Ensure that if we specified that we don't specify any crawled property mapping if we selected to include
        # them all.
        if ($params.IncludeAllCrawledProperties -and $params.CrawledProperties.Length -gt 0)
        {
            throw("You cannot specify values for CrawledProperties if the property `
                IncludeAllCrawledProperties is set to True.")
        }

        # Ensure that the specified crawled properties exist
        foreach ($mappedCrawlProperty in $params.CrawledProperties)
        {
            $currentCrawlProperty = Get-SPEnterpriseSearchMetadataCrawledProperty -Name $mappedCrawlProperty `
                                                                                  -SearchApplication $params.ServiceAppName
            if (!$currentCrawlProperty)
            {
                throw("The specified crawled property $($mappedCrawlProperty) does not exist. `
                    Please make sure you specify valid existing crawl properties.")
            }
        }
        #endregion
        $needToRecreate = $false

        # If the property should not be present and is, or if it should be present bu the current property type
        # differs from the desired one.
        if ($params.Ensure -eq "Absent" -and $CurrentValues.Ensure -eq "Present" -or `
        ($params.PropertyType -ne $CurrentValues.PropertyType -and `
        $CurrentValues.Ensure -eq "Present"))
        {
            $managedProperty = Get-SPEnterpriseSearchMetadataManagedProperty -Identity $params.Name `
                                                                         -SearchApplication $params.ServiceAppName

            # In order to delete a Managed PRoperty we need to make sure it doesn't have any crawled properties
            # mapped to it first.
            $managedProperty.DeleteAllMappings()

            # Remove the existing managed property
            Write-Verbose  "Removing Managed Property $($params.Name)"
            Remove-SPEnterpriseSearchMetadataManagedProperty -Identity $params.Name `
                                                             -SearchApplication $params.ServiceAppName `
                                                             -Confirm:$false

            if ($params.PropertyType -ne $CurrentValues.PropertyType)
            {
                Write-Verbose "Detected a change to type from $($currentPropertyType) to `
                               $($params.PropertyType)"
                $needToRecreate = $true
            }
        }

        # Managed Property doesn't exist but should or if we are recreating because of a type change
        if (($CurrentValues.Ensure -eq "Absent" -and $params.Ensure -eq "Present") -or $needToRecreate)
        {
            # Create the new content source and then apply settings to it
            $managedTypeID = [Microsoft.Office.Server.Search.Administration.ManagedDataType]::$($params.PropertyType).value__

            Write-Verbose "Creating a new Managed Property $($params.Name)"
            New-SPEnterpriseSearchMetadataManagedProperty -Name $params.Name `
                                                          -SearchApplication $params.ServiceAppName `
                                                          -Type $managedTypeID
        }

        # Set the specified properties on the Managed Property
        $managedProperty = Get-SPEnterpriseSearchMetadataManagedProperty -Identity $params.Name `
                                                                         -SearchApplication $params.ServiceAppName

        Set-SPEnterpriseSearchMetadataManagedProperty -Identity $managedProperty.Name `
                                                      -SearchApplication $params.ServiceAppName `
                                                      -Retrievable $params.Retrievable `
                                                      -SafeForAnonymous $params.SafeForAnonymous `
                                                      -NoWordBreaker $params.NoWordBreaker

        $managedProperty.HasMultipleValues = $params.HasMultipleValues
        $managedProperty.Searchable = $params.Searchable
        $managedProperty.Queryable = $params.Queryable
        $managedProperty.Refinable = $params.Refinable
        $managedProperty.Sortable = $params.Sortable
        $managedProperty.TokenNormalization = $params.TokenNormalization
        $managedProperty.RespectPriority = !($params.IncludeAllCrawledProperties)
        $managedProperty.OverrideValueOfHasMultipleValues = !($params.IncludeAllCrawledProperties)


        # If alias doesn't already exist, add it
        $currentAliases = $managedProperty.GetAliases()

        foreach($alias in $params.Aliases)
        {
            $currentAlias = $managedProperty.GetAliases() | Where-Object {$_ -eq $alias}
            if(!$currentAlias)
            {
                $managedProperty.AddAlias($alias)
            }
        }
        $managedProperty.Update()

        # Remove the aliases that are different, meaning they currently exist, but were not specified in the config,
        # which means we need to remove them.
        $currentAliases = $managedProperty.GetAliases()

        foreach($alias in $currentAliases)
        {
            if(!$params.Aliases.Contains($alias))
            {
                $managedProperty.DeleteAlias($alias)
            }
        }
        $managedProperty.Update()

        # Generate the Crawled Properties mapping
        $listOfMappedCrawlProperty = [Microsoft.Office.Server.Search.Administration.MappingCollection]::new()
        foreach ($mappedCrawlProperty in $params.CrawledProperties)
        {
            $currentCrawlProperty = Get-SPEnterpriseSearchMetadataCrawledProperty -Name $mappedCrawlProperty `
                                                                                  -SearchApplication $params.ServiceAppName

            $mapping = [Microsoft.Office.Server.Search.Administration.Mapping]::new()
            $mapping.CrawledPropertyName = $mappedCrawlProperty
            $mapping.CrawledPropSet = $currentCrawlProperty.PropSet
            $mapping.ManagedPID = $managedProperty.PId
            $listOfMappedCrawlProperty.Add($mapping)
        }
        $managedProperty.SetMappings($listOfMappedCrawlProperty)
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

        [Parameter(Mandatory = $true)]
        [ValidateSet("Binary","DateTime","Decimal","Double","Integer","Text","YesNo")]
        [System.String]
        $PropertyType,

        [Parameter()]
        [System.Boolean]
        $Searchable,

        [Parameter()]
        [System.Boolean]
        $Queryable,

        [Parameter()]
        [System.Boolean]
        $Retrievable,

        [Parameter()]
        [System.Boolean]
        $HasMultipleValues,

        [Parameter()]
        [System.Boolean]
        $Refinable,

        [Parameter()]
        [System.Boolean]
        $Sortable,

        [Parameter()]
        [System.Boolean]
        $SafeForAnonymous,

        [Parameter()]
        [System.String[]]
        $Aliases,

        [Parameter()]
        [System.Boolean]
        $TokenNormalization,

        [Parameter()]
        [System.Boolean]
        $NoWordBreaker,

        [Parameter()]
        [System.Boolean]
        $IncludeAllCrawledProperties,

        [Parameter()]
        [System.String[]]
        $CrawledProperties,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Managed Property Setting for '$Name'"

    $PSBoundParameters.Ensure = $Ensure
    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Name",
                                                     "PropertyType",
                                                     "Ensure",
                                                     "HasMultipleValues",
                                                     "Retrievable",
                                                     "Searchable",
                                                     "Refinable",
                                                     "Searchable",
                                                     "NoWordBreaker",
                                                     "IncludeAllCrawledProperties",
                                                     "Aliases",
                                                     "Sortable",
                                                     "SafeForAnonymous")
}

Export-ModuleMember -Function *-TargetResource
