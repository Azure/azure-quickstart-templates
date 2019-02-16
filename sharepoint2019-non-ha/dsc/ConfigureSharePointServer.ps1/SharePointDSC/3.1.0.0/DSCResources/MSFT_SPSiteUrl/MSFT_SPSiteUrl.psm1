function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        [Parameter()]
        [System.String]
        $Intranet,

        [Parameter()]
        [System.String]
        $Internet,

        [Parameter()]
        [System.String]
        $Extranet,

        [Parameter()]
        [System.String]
        $Custom,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting site collection url for $Url"

    if ($PSBoundParameters.ContainsKey("Intranet") -eq $false -and
        $PSBoundParameters.ContainsKey("Internet") -eq $false -and
        $PSBoundParameters.ContainsKey("Extranet") -eq $false -and
        $PSBoundParameters.ContainsKey("Custom") -eq $false)
    {
        Write-Verbose -Message "No zone is specified"
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $nullreturn = @{
            Url = $params.Url
        }

        $site = Get-SPSite -Identity $params.Url `
                           -ErrorAction SilentlyContinue

        if ($null -eq $site)
        {
            Write-Verbose -Message "Specified site $($params.Url) does not exist"
            return $nullreturn
        }

        if ($site.HostHeaderIsSiteName -eq $false)
        {
            Write-Verbose -Message ("Specified site $($params.Url) is not a Host Named " + `
                                    "Site Collection")
            return $nullreturn
        }

        $intranetUrl = $null
        $internetUrl = $null
        $extranetUrl = $null
        $customUrl = $null

        $siteurls = Get-SPSiteUrl -Identity $params.Url
        foreach ($siteurl in $siteurls)
        {
            switch ($siteurl.Zone)
            {
                "Default"
                {
                    Write-Verbose -Message "SiteUrl for Default zone is $($siteurl.Url)"
                }
                "Intranet"
                {
                    Write-Verbose -Message "SiteUrl for Intranet zone is $($siteurl.Url)"
                    $intranetUrl = $siteurl.Url
                }
                "Internet"
                {
                    Write-Verbose -Message "SiteUrl for Internet zone is $($siteurl.Url)"
                    $internetUrl = $siteurl.Url
                }
                "Extranet"
                {
                    Write-Verbose -Message "SiteUrl for Extranet zone is $($siteurl.Url)"
                    $extranetUrl = $siteurl.Url
                }
                "Custom"
                {
                    Write-Verbose -Message "SiteUrl for Custom zone is $($siteurl.Url)"
                    $customUrl = $siteurl.Url
                }
            }
        }
        return @{
            Url            = $params.Url
            Intranet       = $intranetUrl
            Internet       = $internetUrl
            Extranet       = $extranetUrl
            Custom         = $customUrl
            InstallAccount = $params.InstallAccount
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
        $Url,

        [Parameter()]
        [System.String]
        $Intranet,

        [Parameter()]
        [System.String]
        $Internet,

        [Parameter()]
        [System.String]
        $Extranet,

        [Parameter()]
        [System.String]
        $Custom,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting site collection url for $Url"

    if ($PSBoundParameters.ContainsKey("Intranet") -eq $false -and
        $PSBoundParameters.ContainsKey("Internet") -eq $false -and
        $PSBoundParameters.ContainsKey("Extranet") -eq $false -and
        $PSBoundParameters.ContainsKey("Custom") -eq $false)
    {
        throw "No zone specified. Please specify a zone"
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        $site = Get-SPSite -Identity $params.Url `
                           -ErrorAction SilentlyContinue

        if ($null -eq $site)
        {
            throw "Specified site $($params.Url) does not exist"
        }

        if ($site.HostHeaderIsSiteName -eq $false)
        {
            throw "Specified site $($params.Url) is not a Host Named Site Collection"
        }

        $siteurls = Get-SPSiteUrl -Identity $params.Url
        foreach ($siteurl in $siteurls)
        {
            switch ($siteurl.Zone)
            {
                "Default"
                {
                    Write-Verbose -Message "SiteUrl for Default zone is $($siteurl.Url)"
                }
                "Intranet"
                {
                    Write-Verbose -Message "SiteUrl for Intranet zone is $($siteurl.Url)"
                    if ($params.Intranet -ne $siteurl.Url)
                    {
                        Remove-SPSiteUrl -Url $siteurl.Url
                    }
                }
                "Internet"
                {
                    Write-Verbose -Message "SiteUrl for Internet zone is $($siteurl.Url)"
                    if ($params.Internet -ne $siteurl.Url)
                    {
                        Remove-SPSiteUrl -Url $siteurl.Url
                    }
                }
                "Extranet"
                {
                    Write-Verbose -Message "SiteUrl for Extranet zone is $($siteurl.Url)"
                    if ($params.Extranet -ne $siteurl.Url)
                    {
                        Remove-SPSiteUrl -Url $siteurl.Url
                    }
                }
                "Custom"
                {
                    Write-Verbose -Message "SiteUrl for Custom zone is $($siteurl.Url)"
                    if ($params.Custom -ne $siteurl.Url)
                    {
                        Remove-SPSiteUrl -Url $siteurl.Url
                    }
                }
            }
        }

        if ($null -ne $params.Intranet)
        {
            $siteurl = Get-SPSiteURL -Identity $params.Intranet -ErrorAction SilentlyContinue
            if ($null -eq $siteurl)
            {
                Set-SPSiteUrl -Identity $params.Url -Zone Intranet -Url $params.Intranet
            }
            else
            {
                throw ("Specified URL $($params.Intranet) (Zone: Intranet) is already assigned " + `
                       "to a site collection: $($siteurl[0].Url)")
            }
        }

        if ($null -ne $params.Internet)
        {
            $siteurl = Get-SPSiteURL -Identity $params.Internet -ErrorAction SilentlyContinue
            if ($null -eq $siteurl)
            {
                Set-SPSiteUrl -Identity $params.Url -Zone Internet -Url $params.Internet
            }
            else
            {
                throw ("Specified URL $($params.Internet) (Zone: Internet) is already assigned " + `
                       "to a site collection: $($siteurl[0].Url)")
            }
        }

        if ($null -ne $params.Extranet)
        {
            $siteurl = Get-SPSiteURL -Identity $params.Extranet -ErrorAction SilentlyContinue
            if ($null -eq $siteurl)
            {
                Set-SPSiteUrl -Identity $params.Url -Zone Extranet -Url $params.Extranet
            }
            else
            {
                throw ("Specified URL $($params.Extranet) (Zone: Extranet) is already assigned " + `
                       "to a site collection: $($siteurl[0].Url)")
            }
        }

        if ($null -ne $params.Custom)
        {
            $siteurl = Get-SPSiteURL -Identity $params.Custom -ErrorAction SilentlyContinue
            if ($null -eq $siteurl)
            {
                Set-SPSiteUrl -Identity $params.Url -Zone Custom -Url $params.Custom
            }
            else
            {
                throw ("Specified URL $($params.Custom) (Zone: Custom) is already assigned " + `
                       "to a site collection: $($siteurl[0].Url)")
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
        $Url,

        [Parameter()]
        [System.String]
        $Intranet,

        [Parameter()]
        [System.String]
        $Internet,

        [Parameter()]
        [System.String]
        $Extranet,

        [Parameter()]
        [System.String]
        $Custom,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing site collection url for $Url"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues.Intranet -and
        $null -eq $CurrentValues.Internet -and
        $null -eq $CurrentValues.Extranet -and
        $null -eq $CurrentValues.Custom)
    {
        return $false
    }

    if ([String]$CurrentValues.Intranet -ne $Intranet)
    {
        return $false
    }

    if ([String]$CurrentValues.Internet -ne $Internet)
    {
        return $false
    }

    if ([String]$CurrentValues.Extranet -ne $Extranet)
    {
        return $false
    }

    if ([String]$CurrentValues.Custom -ne $Custom)
    {
        return $false
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
