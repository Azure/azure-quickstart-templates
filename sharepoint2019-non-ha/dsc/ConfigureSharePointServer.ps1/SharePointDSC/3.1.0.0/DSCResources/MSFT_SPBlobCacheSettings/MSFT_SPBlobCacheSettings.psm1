function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default", "Intranet", "Internet", "Custom", "Extranet")]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $EnableCache,

        [Parameter()]
        [System.String]
        $Location,

        [Parameter()]
        [System.UInt16]
        $MaxSizeInGB,

        [Parameter()]
        [System.UInt32]
        $MaxAgeInSeconds,

        [Parameter()]
        [System.String]
        $FileTypes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting blob cache settings for $WebAppUrl"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $webappsi = Get-SPServiceInstance -Server $env:COMPUTERNAME `
                                          -ErrorAction SilentlyContinue `
                        | Where-Object -FilterScript {
                            $_.GetType().Name -eq "SPWebServiceInstance" -and `
                            $_.Name -eq ""
                          }

        if ($null -eq $webappsi)
        {
            Write-Verbose -Message "Server isn't running the Web Application role"
            return @{
                WebAppUrl = $null
                Zone = $null
                EnableCache = $false
                Location = $null
                MaxSizeInGB = $null
                MaxAgeInSeconds = $null
                FileTypes = $null
                InstallAccount = $params.InstallAccount
            }
        }

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl `
                                   -ErrorAction SilentlyContinue

        if ($null -eq $wa)
        {
            Write-Verbose -Message "Specified web application was not found."
            return @{
                WebAppUrl = $null
                Zone = $null
                EnableCache = $false
                Location = $null
                MaxSizeInGB = $null
                MaxAgeInSeconds = $null
                FileTypes = $null
                InstallAccount = $params.InstallAccount
            }
        }

        $zone = [Microsoft.SharePoint.Administration.SPUrlZone]::$($params.Zone)

        $sitePath = $wa.IisSettings[$zone].Path
        $webconfiglocation = Join-Path $sitePath "web.config"

        [xml]$webConfig = Get-Content -Path $webConfigLocation

        if ($webconfig.configuration.SharePoint.BlobCache.enabled -eq "true")
        {
            $cacheEnabled = $true
        }
        else
        {
            $cacheEnabled = $false
        }

        try
        {
            $maxsize = [Convert]::ToUInt16($webconfig.configuration.SharePoint.BlobCache.maxSize)
        }
        catch [FormatException]
        {
            $maxsize = 0
        }
        catch
        {
            throw "Error: $($_.Exception.Message)"
        }

        try
        {
            $maxage = [Convert]::ToUInt32($webconfig.configuration.SharePoint.BlobCache."max-age")
        }
        catch [FormatException]
        {
            $maxage = 0
        }
        catch
        {
            throw "Error: $($_.Exception.Message)"
        }

        $returnval = @{
            WebAppUrl = $params.WebAppUrl
            Zone = $params.Zone
            EnableCache = $cacheEnabled
            Location = $webconfig.configuration.SharePoint.BlobCache.location
            MaxSizeInGB = $maxsize
            MaxAgeInSeconds = $maxage
            FileTypes = $webconfig.configuration.SharePoint.BlobCache.path
            InstallAccount = $params.InstallAccount
        }

        return $returnval
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
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default", "Intranet", "Internet", "Custom", "Extranet")]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $EnableCache,

        [Parameter()]
        [System.String]
        $Location,

        [Parameter()]
        [System.UInt16]
        $MaxSizeInGB,

        [Parameter()]
        [System.UInt32]
        $MaxAgeInSeconds,

        [Parameter()]
        [System.String]
        $FileTypes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting blob cache settings for $WebAppUrl"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $changes = @{}

    if ($PSBoundParameters.ContainsKey("EnableCache"))
    {
        if ($CurrentValues.EnableCache -ne $EnableCache)
        {
            $changes.EnableCache = $EnableCache
        }
    }

    if ($PSBoundParameters.ContainsKey("Location"))
    {
        if ($CurrentValues.Location -ne $Location)
        {
            $changes.Location = $Location
        }
    }

    if ($PSBoundParameters.ContainsKey("MaxSizeInGB"))
    {
        if ($CurrentValues.MaxSizeInGB -ne $MaxSizeInGB)
        {
            $changes.MaxSizeInGB = $MaxSizeInGB
        }
    }

    if ($PSBoundParameters.ContainsKey("MaxAgeInSeconds"))
    {
        if ($CurrentValues.MaxAgeInSeconds -ne $MaxAgeInSeconds)
        {
            $changes.MaxAgeInSeconds = $MaxAgeInSeconds
        }
    }

    if ($PSBoundParameters.ContainsKey("FileTypes"))
    {
        if ($CurrentValues.FileTypes -ne $FileTypes)
        {
            $changes.FileTypes = $FileTypes
        }
    }

    if ($changes.Count -ne 0)
    {
        ## Perform changes
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments @($PSBoundParameters, $changes) `
                            -ScriptBlock {
            $params  = $args[0]
            $changes = $args[1]

            $webappsi = Get-SPServiceInstance -Server $env:COMPUTERNAME `
                                                    -ErrorAction SilentlyContinue `
                            | Where-Object -FilterScript {
                                $_.GetType().Name -eq "SPWebServiceInstance" -and `
                                $_.Name -eq ""
                            }

            if ($null -eq $webappsi)
            {
                throw "Server isn't running the Web Application role"
            }

            $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

            if ($null -eq $wa)
            {
                throw "Specified web application could not be found."
            }

            Write-Verbose -Message "Processing changes"

            $zone = [Microsoft.SharePoint.Administration.SPUrlZone]::$($params.Zone)

            $sitePath = $wa.IisSettings[$zone].Path
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $webconfiglocation = Join-Path -Path $sitePath -ChildPath "web.config"
            $webconfigbackuplocation = Join-Path -Path $sitePath -ChildPath "web_config-$timestamp.backup"
            Copy-Item -Path $webconfiglocation -Destination $webconfigbackuplocation

            [xml]$webConfig = Get-Content -Path $webConfigLocation

            if ($changes.ContainsKey("EnableCache"))
            {
                $webconfig.configuration.SharePoint.BlobCache.SetAttribute("enabled",$changes.EnableCache.ToString())
            }

            if ($changes.ContainsKey("Location"))
            {
                $webconfig.configuration.SharePoint.BlobCache.SetAttribute("location",$changes.Location)
            }

            if ($changes.ContainsKey("MaxSizeInGB"))
            {
                $webconfig.configuration.SharePoint.BlobCache.SetAttribute("maxSize",$changes.MaxSizeInGB.ToString())
            }

            if ($changes.ContainsKey("MaxAgeInSeconds"))
            {
                $webconfig.configuration.SharePoint.BlobCache.SetAttribute("max-age",$($changes.MaxAgeInSeconds.ToString()))
            }

            if ($changes.ContainsKey("FileTypes"))
            {
                $webconfig.configuration.SharePoint.BlobCache.SetAttribute("path",$changes.FileTypes)
            }
            $webconfig.Save($webconfiglocation)
        }
    }

    ## Check Blob Cache folder
    if ($Location)
    {
        if ( -not (Test-Path -Path $Location))
        {
            Write-Verbose "Create Blob Cache Folder $Location"
            try
            {
                New-Item -Path $Location -ItemType Directory | Out-Null
            }
            catch [DriveNotFoundException]
            {
                throw "Specified drive does not exist"
            }
            catch
            {
                throw "Error creating Blob Cache folder: $($_.Exception.Message)"
            }
        }
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
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Default", "Intranet", "Internet", "Custom", "Extranet")]
        [System.String]
        $Zone,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $EnableCache,

        [Parameter()]
        [System.String]
        $Location,

        [Parameter()]
        [System.UInt16]
        $MaxSizeInGB,

        [Parameter()]
        [System.UInt32]
        $MaxAgeInSeconds,

        [Parameter()]
        [System.String]
        $FileTypes,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing blob cache settings for $WebAppUrl"

    if ($Location)
    {
        if ( -not (Test-Path -Path $Location))
        {
            Write-Verbose "Blob Cache Folder $Location does not exist"
            return $false
        }
    }

    return Test-SPDscParameterState -CurrentValues (Get-TargetResource @PSBoundParameters) `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("EnableCache",
                                                     "Location",
                                                     "MaxSizeInGB",
                                                     "FileType",
                                                     "MaxAgeInSeconds")
}

Export-ModuleMember -Function *-TargetResource
