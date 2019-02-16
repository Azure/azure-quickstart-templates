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
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.Boolean]
        $OnlineEnabled,

        [Parameter()]
        [System.String]
        $QuotaTemplate,

        [Parameter()]
        [System.Boolean]
        $ShowStartASiteMenuItem,

        [Parameter()]
        [System.Boolean]
        $CreateIndividualSite,

        [Parameter()]
        [System.String]
        $ParentSiteUrl,

        [Parameter()]
        [ValidateSet("MustHavePolicy","CanHavePolicy","NotHavePolicy")]
        [System.String]
        $PolicyOption,

        [Parameter()]
        [System.Boolean]
        $RequireSecondaryContact,

        [Parameter()]
        [System.String]
        $CustomFormUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting self service site creation settings for Web Application '$WebAppUrl'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $webApplication = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($null -eq $webApplication)
        {
            Write-Verbose "Web application $($params.WebAppUrl) was not found"
            return @{
                WebAppUrl = $null
                Enabled = $null
                OnlineEnabled = $null
                QuotaTemplate = $null
                ShowStartASiteMenuItem = $null
                CreateIndividualSite = $null
                ParentSiteUrl = $null
                CustomFormUrl = $null
                PolicyOption = $null
                RequireSecondaryContact = $null
            }
        }

        $policyOption = "NotHavePolicy"
        if($webApplication.Properties.Contains("PolicyOption"))
        {
            $policyOptionProperty = $webApplication.Properties["PolicyOption"]
            if($policyOptionProperty -eq "CanHavePolicy" -or $policyOptionProperty -eq "MustHavePolicy")
            {
                $policyOption = $policyOptionProperty
            }
        }

        return @{
            WebAppUrl = $params.WebAppUrl
            Enabled = $webApplication.SelfServiceSiteCreationEnabled
            OnlineEnabled = $webApplication.SelfServiceSiteCreationOnlineEnabled
            QuotaTemplate = $webApplication.SelfServiceCreationQuotaTemplate
            ShowStartASiteMenuItem = $webApplication.ShowStartASiteMenuItem
            CreateIndividualSite = $webApplication.SelfServiceCreateIndividualSite
            ParentSiteUrl = $webApplication.SelfServiceCreationParentSiteUrl
            CustomFormUrl = $webApplication.SelfServiceSiteCustomFormUrl
            PolicyOption = $policyOption
            RequireSecondaryContact = $webApplication.RequireContactForSelfServiceSiteCreation
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
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.Boolean]
        $OnlineEnabled,

        [Parameter()]
        [System.String]
        $QuotaTemplate,

        [Parameter()]
        [System.Boolean]
        $ShowStartASiteMenuItem,

        [Parameter()]
        [System.Boolean]
        $CreateIndividualSite,

        [Parameter()]
        [System.String]
        $ParentSiteUrl,

        [Parameter()]
        [ValidateSet("MustHavePolicy","CanHavePolicy","NotHavePolicy")]
        [System.String]
        $PolicyOption,

        [Parameter()]
        [System.Boolean]
        $RequireSecondaryContact,

        [Parameter()]
        [System.String]
        $CustomFormUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting self service site creation settings for Web Application '$WebAppUrl'"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        $webApplication = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($null -eq $webApplication)
        {
            throw "The specified web application could not be found."
        }

        $webApplicationNeedsUpdate = $false

        if ($params.Enabled -eq $false)
        {
            if($params.ContainsKey("ShowStartASiteMenuItem"))
            {
                if($ShowStartASiteMenuItem -eq $true)
                {
                    throw ("It is not allowed to set the ShowStartASiteMenuItem to true when self service site creation is disabled.")
                }
            }
            else
            {
                $params.Add("ShowStartASiteMenuItem", $false)
            }
        }

        if ($params.Enabled -ne $webApplication.SelfServiceSiteCreationEnabled)
        {
            $webApplication.SelfServiceSiteCreationEnabled = $params.Enabled
            $webApplicationNeedsUpdate = $true
        }

        if ($params.ContainsKey("OnlineEnabled") -eq $true)
        {
            if ($params.OnlineEnabled -ne $webApplication.SelfServiceSiteCreationOnlineEnabled)
            {
                $webApplication.SelfServiceSiteCreationOnlineEnabled = $params.OnlineEnabled
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("QuotaTemplate") -eq $true)
        {
            if ($params.QuotaTemplate -ne $webApplication.SelfServiceCreationQuotaTemplate)
            {
                $webApplication.SelfServiceCreationQuotaTemplate = $params.QuotaTemplate
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("ShowStartASiteMenuItem") -eq $true)
        {
            if ($params.ShowStartASiteMenuItem -ne $webApplication.ShowStartASiteMenuItem)
            {
                $webApplication.ShowStartASiteMenuItem = $params.ShowStartASiteMenuItem
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("CreateIndividualSite") -eq $true)
        {
            if ($params.CreateIndividualSite -ne $webApplication.SelfServiceCreateIndividualSite)
            {
                $webApplication.SelfServiceCreateIndividualSite = $params.CreateIndividualSite
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("ParentSiteUrl") -eq $true)
        {
            if ($params.ParentSiteUrl -ne $webApplication.SelfServiceCreationParentSiteUrl)
            {
                $webApplication.SelfServiceCreationParentSiteUrl = $params.ParentSiteUrl
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("CustomFormUrl") -eq $true)
        {
            if ($params.CustomFormUrl -ne $webApplication.SelfServiceSiteCustomFormUrl)
            {
                $webApplication.SelfServiceSiteCustomFormUrl = $params.CustomFormUrl
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("PolicyOption") -eq $true)
        {
            if ($params.PolicyOption -ne $webApplication.Properties["PolicyOption"])
            {
                $webApplication.Properties["PolicyOption"] = $params.PolicyOption
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($params.ContainsKey("RequireSecondaryContact") -eq $true)
        {
            if ($params.RequireSecondaryContact -ne $webApplication.RequireContactForSelfServiceSiteCreation)
            {
                $webApplication.RequireContactForSelfServiceSiteCreation = $params.RequireSecondaryContact
                $webApplicationNeedsUpdate = $true
            }
        }

        if ($webApplicationNeedsUpdate -eq $true)
        {
            Write-Verbose -Message "Updating web application"
            $webApplication.Update()
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
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.Boolean]
        $OnlineEnabled,

        [Parameter()]
        [System.String]
        $QuotaTemplate,

        [Parameter()]
        [System.Boolean]
        $ShowStartASiteMenuItem,

        [Parameter()]
        [System.Boolean]
        $CreateIndividualSite,

        [Parameter()]
        [System.String]
        $ParentSiteUrl,

        [Parameter()]
        [ValidateSet("MustHavePolicy","CanHavePolicy","NotHavePolicy")]
        [System.String]
        $PolicyOption,

        [Parameter()]
        [System.Boolean]
        $RequireSecondaryContact,

        [Parameter()]
        [System.String]
        $CustomFormUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing self service site creation settings for Web Application '$WebAppUrl'"

    if ($Enabled -eq $false)
    {
        if($PSBoundParameters.ContainsKey("ShowStartASiteMenuItem"))
        {
            if($ShowStartASiteMenuItem -eq $true)
            {
                throw ("It is not allowed to set the ShowStartASiteMenuItem to true when self service site creation is disabled.")
            }
        }
        else
        {
            $PSBoundParameters.Add("ShowStartASiteMenuItem", $false)
        }
    }

    $currentValues = Get-TargetResource @PSBoundParameters

    if ($Enabled)
    {
        return Test-SPDscParameterState -CurrentValues $currentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("WebAppUrl", `
                                                         "Enabled", `
                                                         "OnlineEnabled", `
                                                         "ShowStartASiteMenuItem", `
                                                         "CreateIndividualSite", `
                                                         "ParentSiteUrl", `
                                                         "CustomFormUrl", `
                                                         "PolicyOption", `
                                                         "RequireSecondaryContact")
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $currentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("WebAppUrl", `
                                                         "Enabled", `
                                                         "ShowStartASiteMenuItem")
    }
}
