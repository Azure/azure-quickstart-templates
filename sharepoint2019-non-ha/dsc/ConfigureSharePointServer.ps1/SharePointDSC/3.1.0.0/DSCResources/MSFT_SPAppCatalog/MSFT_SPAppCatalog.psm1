function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SiteUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting app catalog status of $SiteUrl"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $site = Get-SPSite $params.SiteUrl -ErrorAction SilentlyContinue
        $nullreturn = @{
            SiteUrl = $null
            InstallAccount = $params.InstallAccount
        }
        if ($null -eq $site)
        {
            return $nullreturn
        }
        $wa = $site.WebApplication
        $feature = $wa.Features.Item([Guid]::Parse("f8bea737-255e-4758-ab82-e34bb46f5828"))
        if ($null -eq $feature)
        {
            return $nullreturn
        }
        if ($site.ID -ne $feature.Properties["__AppCatSiteId"].Value)
        {
            return $nullreturn
        }
        return @{
            SiteUrl = $site.Url
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
        $SiteUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting app catalog status of $SiteUrl"

    Write-Verbose -Message "Retrieving farm account"
    $farmAccount = Invoke-SPDSCCommand -Credential $InstallAccount `
                                       -Arguments $PSBoundParameters `
                                       -ScriptBlock {
        return Get-SPDscFarmAccount
    }

    Write-Verbose -Message "Check if InstallAccount or PsDscRunAsCredential is the farm account"
    if ($null -ne $farmAccount)
    {
        if ($PSBoundParameters.ContainsKey("InstallAccount") -eq $true)
        {
            # InstallAccount used
            if ($InstallAccount.UserName -eq $farmAccount.UserName)
            {
                throw ("Specified InstallAccount ($($InstallAccount.UserName)) is the Farm " + `
                        "Account. Make sure the specified InstallAccount isn't the Farm Account " + `
                        "and try again")
            }
        }
        else
        {
            # PSDSCRunAsCredential or System
            if (-not $Env:USERNAME.Contains("$"))
            {
                # PSDSCRunAsCredential used
                $localaccount = "$($Env:USERDOMAIN)\$($Env:USERNAME)"
                if ($localaccount -eq $farmAccount.UserName)
                {
                    throw ("Specified PSDSCRunAsCredential ($localaccount) is the Farm " + `
                            "Account. Make sure the specified PSDSCRunAsCredential isn't the " + `
                            "Farm Account and try again")
                }
            }
        }
    }
    else
    {
        throw ("Unable to retrieve the Farm Account. Check if the farm exists.")
    }

    # Add the FarmAccount to the local Administrators group, if it's not already there
    $isLocalAdmin = Test-SPDSCUserIsLocalAdmin -UserName $farmAccount.UserName

    if (!$isLocalAdmin)
    {
        Write-Verbose -Message "Adding farm account to Local Administrators group"
        Add-SPDSCUserToLocalAdmin -UserName $farmAccount.UserName

        # Cycle the Timer Service and flush Kerberos tickets
        # so that it picks up the local Admin token
        Restart-Service -Name "SPTimerV4"

        Clear-SPDscKerberosToken -Account $farmAccount.UserName
    }

    Invoke-SPDSCCommand -Credential $farmAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
        try
        {
            Update-SPAppCatalogConfiguration -Site $params.SiteUrl -Confirm:$false
        }
        catch [System.UnauthorizedAccessException]
        {
            throw ("This resource must be run as the farm account (not a setup account). " + `
                   "Please ensure either the PsDscRunAsCredential or InstallAccount " + `
                   "credentials are set to the farm account and run this resource again")
        }
    } | Out-Null

    # Remove the FarmAccount from the local Administrators group, if it was added above
    if (!$isLocalAdmin)
    {
        Write-Verbose -Message "Removing farm account from Local Administrators group"
        Remove-SPDSCUserToLocalAdmin -UserName $farmAccount.UserName

        # Cycle the Timer Service and flush Kerberos tickets
        # so that it picks up the local Admin token
        Restart-Service -Name "SPTimerV4"

        Clear-SPDscKerberosToken -Account $farmAccount.UserName
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
        $SiteUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing app catalog status of $SiteUrl"

    return Test-SPDscParameterState -CurrentValues (Get-TargetResource @PSBoundParameters) `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("SiteUrl")
}

Export-ModuleMember -Function *-TargetResource
