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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.UInt32]
        $Language,

        [Parameter()]
        [System.String]
        $Template,

        [Parameter()]
        [System.Boolean]
        $UniquePermissions,

        [Parameter()]
        [System.Boolean]
        $UseParentTopNav,

        [Parameter()]
        [System.Boolean]
        $AddToQuickLaunch,

        [Parameter()]
        [System.Boolean]
        $AddToTopNav,

        [Parameter()]
        [System.String]
        $RequestAccessEmail,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting SPWeb '$Url'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
        -Arguments $PSBoundParameters `
        -ScriptBlock {
        $params = $args[0]

        $web = Get-SPWeb -Identity $params.Url -ErrorAction SilentlyContinue

        if ($web)
        {
            $ensureResult = "Present"
            $templateResult = "$($web.WebTemplate)#$($web.WebTemplateId)"
            $parentTopNav = $web.Navigation.UseShared
        }
        else
        {
            $ensureResult = "Absent"
        }

        return @{
            Url                = $web.Url
            Ensure             = $ensureResult
            Description        = $web.Description
            Name               = $web.Title
            Language           = $web.Language
            Template           = $templateResult
            UniquePermissions  = $web.HasUniquePerm
            UseParentTopNav    = $parentTopNav
            RequestAccessEmail = $web.RequestAccessEmail
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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.UInt32]
        $Language,

        [Parameter()]
        [System.String]
        $Template,

        [Parameter()]
        [System.Boolean]
        $UniquePermissions,

        [Parameter()]
        [System.Boolean]
        $UseParentTopNav,

        [Parameter()]
        [System.Boolean]
        $AddToQuickLaunch,

        [Parameter()]
        [System.Boolean]
        $AddToTopNav,

        [Parameter()]
        [System.String]
        $RequestAccessEmail,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting SPWeb '$Url'"

    $PSBoundParameters.Ensure = $Ensure

    Invoke-SPDSCCommand -Credential $InstallAccount `
        -Arguments $PSBoundParameters `
        -ScriptBlock {
        $params = $args[0]

        if ($null -eq $params.InstallAccount)
        {
            $currentUserName = "$env:USERDOMAIN\$env:USERNAME"
        }
        else
        {
            $currentUserName = $params.InstallAccount.UserName
        }

        Write-Verbose "Grant user '$currentUserName' Access To Process Identity for '$($params.Url)'..."
        $site = New-Object -Type Microsoft.SharePoint.SPSite -ArgumentList $params.Url
        $site.WebApplication.GrantAccessToProcessIdentity($currentUserName)

        $web = Get-SPWeb -Identity $params.Url -ErrorAction SilentlyContinue

        if ($null -eq $web)
        {
            @("InstallAccount", "Ensure", "RequestAccessEmail") |
                ForEach-Object -Process {
                    if ($params.ContainsKey($_) -eq $true)
                    {
                        $params.Remove($_) | Out-Null
                    }
                }

            New-SPWeb @params | Out-Null
        }
        else
        {
            if ($params.Ensure -eq "Absent")
            {
                Remove-SPweb $params.Url -confirm:$false
            }
            else
            {
                $changedWeb = $false

                if (($params.ContainsKey("Name") -eq $true) `
                        -and $web.Title -ne $params.Name)
                {
                    $web.Title = $params.Name
                    $changedWeb = $true
                }

                if (($params.ContainsKey("Description") -eq $true) `
                        -and $web.Description -ne $params.Description)
                {
                    $web.Description = $params.Description
                    $changedWeb = $true
                }

                if (($params.ContainsKey("UseParentTopNav") -eq $true) `
                        -and $web.Navigation.UseShared -ne $params.UseParentTopNav)
                {
                    $web.Navigation.UseShared = $params.UseParentTopNav
                    $changedWeb = $true
                }

                if (($params.ContainsKey("UniquePermissions") -eq $true) `
                        -and $web.HasUniquePerm -ne $params.UniquePermissions)
                {
                    $web.HasUniquePerm = $params.UniquePermissions
                    $changedWeb = $true
                }

                if ($params.ContainsKey("RequestAccessEmail") -eq $true)
                {
                    if ($web.RequestAccessEmail -ne $params.RequestAccessEmail -and $web.HasUniquePerm)
                    {
                        if ([Boolean]$params.RequestAccessEmail -as [System.Net.Mail.MailAddress])
                        {
                            Write-Verbose "The Request Access Email $($params.RequestAccessEmail) is not a valid mail address."
                        }
                        # Workaround to allow empty addresses to disable the access request as RequestAccessEnabled is read only
                        $web.RequestAccessEmail = $params.RequestAccessEmail
                        $changedWeb = $true
                    }
                    else
                    {
                        Write-Verbose "The Request Access Email $($params.RequestAccessEmail) can only be set, if the web has unique permissions."
                    }
                }

                if ($changedWeb)
                {
                    $web.Update()
                }
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
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.UInt32]
        $Language,

        [Parameter()]
        [System.String]
        $Template,

        [Parameter()]
        [System.Boolean]
        $UniquePermissions,

        [Parameter()]
        [System.Boolean]
        $UseParentTopNav,

        [Parameter()]
        [System.Boolean]
        $AddToQuickLaunch,

        [Parameter()]
        [System.Boolean]
        $AddToTopNav,

        [Parameter()]
        [System.String]
        $RequestAccessEmail,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing SPWeb '$Url'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    $valuesToCheck = @("Url",
        "Name",
        "Description",
        "UniquePermissions",
        "UseParentTopNav",
        "Ensure")

    if ($CurrentValues.UniquePermissions)
    {
        $valuesToCheck = @("Url",
            "Name",
            "Description",
            "UniquePermissions",
            "UseParentTopNav",
            "RequestAccessEmail",
            "Ensure")
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $valuesToCheck
}

Export-ModuleMember -Function *-TargetResource
