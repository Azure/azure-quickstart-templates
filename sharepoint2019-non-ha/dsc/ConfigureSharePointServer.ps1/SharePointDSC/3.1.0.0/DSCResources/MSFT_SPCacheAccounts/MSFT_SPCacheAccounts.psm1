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
        [System.String]
        $SuperUserAlias,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SuperReaderAlias,

        [Parameter()]
        [System.Boolean]
        $SetWebAppPolicy = $true,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting cache accounts for $WebAppUrl"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($null -eq $wa)
        {
            return @{
                WebAppUrl = $params.WebAppUrl
                SuperUserAlias = $null
                SuperReaderAlias = $null
                SetWebAppPolicy = $false
                InstallAccount = $params.InstallAccount
            }
        }

        $returnVal = @{
            InstallAccount = $params.InstallAccount
            WebAppUrl = $params.WebAppUrl
        }

        $policiesSet = $true
        if ($wa.UseClaimsAuthentication -eq $true)
        {
            if ($wa.Properties.ContainsKey("portalsuperuseraccount"))
            {
                $claim = New-SPClaimsPrincipal -Identity $wa.Properties["portalsuperuseraccount"] `
                                               -IdentityType EncodedClaim `
                                               -ErrorAction SilentlyContinue
                if ($null -ne $claim)
                {
                    $returnVal.Add("SuperUserAlias", $claim.Value)
                }
                else
                {
                    $returnVal.Add("SuperUserAlias", "")
                }
            }
            else
            {
                $returnVal.Add("SuperUserAlias", "")
            }
            if ($wa.Properties.ContainsKey("portalsuperreaderaccount"))
            {
                $claim = New-SPClaimsPrincipal -Identity $wa.Properties["portalsuperreaderaccount"] `
                                               -IdentityType EncodedClaim `
                                               -ErrorAction SilentlyContinue
                if ($null -ne $claim)
                {
                    $returnVal.Add("SuperReaderAlias", $claim.Value)
                }
                else
                {
                    $returnVal.Add("SuperReaderAlias", "")
                }
            }
            else
            {
                $returnVal.Add("SuperReaderAlias", "")
            }
            if ($wa.Policies.UserName -notcontains ((New-SPClaimsPrincipal -Identity $params.SuperReaderAlias `
                                                                           -IdentityType WindowsSamAccountName).ToEncodedString()))
            {
                $policiesSet = $false
            }

            if ($wa.Policies.UserName -notcontains ((New-SPClaimsPrincipal -Identity $params.SuperUserAlias `
                                                                           -IdentityType WindowsSamAccountName).ToEncodedString()))
            {
                $policiesSet = $false
            }
        }
        else
        {
            if ($wa.Properties.ContainsKey("portalsuperuseraccount"))
            {
                $returnVal.Add("SuperUserAlias", $wa.Properties["portalsuperuseraccount"])
            }
            else
            {
                $returnVal.Add("SuperUserAlias", "")
            }

            if ($wa.Properties.ContainsKey("portalsuperreaderaccount"))
            {
                $returnVal.Add("SuperReaderAlias", $wa.Properties["portalsuperreaderaccount"])
            }
            else
            {
                $returnVal.Add("SuperReaderAlias", "")
            }

            if ($wa.Policies.UserName -notcontains $params.SuperReaderAlias)
            {
                $policiesSet = $false
            }

            if ($wa.Policies.UserName -notcontains $params.SuperUserAlias)
            {
                $policiesSet = $false
            }
        }
        $returnVal.Add("SetWebAppPolicy", $policiesSet)

        return $returnVal
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
        [System.String]
        $SuperUserAlias,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SuperReaderAlias,

        [Parameter()]
        [System.Boolean]
        $SetWebAppPolicy = $true,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount    )

    Write-Verbose -Message "Setting cache accounts for $WebAppUrl"

    $PSBoundParameters.SetWebAppPolicy = $SetWebAppPolicy

    Invoke-SPDSCCommand -Credential $InstallAccount -Arguments $PSBoundParameters -ScriptBlock {
        $params = $args[0]

        $wa = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue
        if ($null -eq $wa)
        {
            throw [Exception] "The web applications $($params.WebAppUrl) can not be found to set cache accounts"
        }

        if ($wa.UseClaimsAuthentication -eq $true)
        {
            $wa.Properties["portalsuperuseraccount"] = (New-SPClaimsPrincipal -Identity $params.SuperUserAlias `
                                                                              -IdentityType WindowsSamAccountName).ToEncodedString()
            $wa.Properties["portalsuperreaderaccount"] = (New-SPClaimsPrincipal -Identity $params.SuperReaderAlias `
                                                                                -IdentityType WindowsSamAccountName).ToEncodedString()
        }
        else
        {
            $wa.Properties["portalsuperuseraccount"] = $params.SuperUserAlias
            $wa.Properties["portalsuperreaderaccount"] = $params.SuperReaderAlias
        }

        if ($params.SetWebAppPolicy -eq $true)
        {
            if ($wa.UseClaimsAuthentication -eq $true)
            {
                $claimsReader = (New-SPClaimsPrincipal -Identity $params.SuperReaderAlias `
                                                       -IdentityType WindowsSamAccountName).ToEncodedString()
                if ($wa.Policies.UserName -contains $claimsReader)
                {
                    $wa.Policies.Remove($claimsReader)
                }
                $policy = $wa.Policies.Add($claimsReader, "Super Reader (Claims)")
                $policyRole = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullRead)
                $policy.PolicyRoleBindings.Add($policyRole)

                $claimsSuper = (New-SPClaimsPrincipal -Identity $params.SuperUserAlias `
                                                      -IdentityType WindowsSamAccountName).ToEncodedString()
                if ($wa.Policies.UserName -contains $claimsSuper)
                {
                    $wa.Policies.Remove($claimsSuper)
                }
                $policy = $wa.Policies.Add($claimsSuper, "Super User (Claims)")
                $policyRole = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullControl)
                $policy.PolicyRoleBindings.Add($policyRole)
            }
            else
            {
                if ($wa.Policies.UserName -contains $params.SuperReaderAlias)
                {
                    $wa.Policies.Remove($params.SuperReaderAlias)
                }

                $readPolicy = $wa.Policies.Add($params.SuperReaderAlias, "Super Reader")
                $readPolicyRole = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullRead)
                $readPolicy.PolicyRoleBindings.Add($readPolicyRole)

                if ($wa.Policies.UserName -contains $params.SuperUserAlias)
                {
                    $wa.Policies.Remove($params.SuperUserAlias)
                }
                $policy = $wa.Policies.Add($params.SuperUserAlias, "Super User")
                $policyRole = $wa.PolicyRoles.GetSpecialRole([Microsoft.SharePoint.Administration.SPPolicyRoleType]::FullControl)
                $policy.PolicyRoleBindings.Add($policyRole)
            }
        }

        $wa.Update()
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
        [System.String]
        $SuperUserAlias,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SuperReaderAlias,

        [Parameter()]
        [System.Boolean]
        $SetWebAppPolicy = $true,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount    )

    Write-Verbose -Message "Testing cache accounts for $WebAppUrl"

    $PSBoundParameters.SetWebAppPolicy = $SetWebAppPolicy

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($SetWebAppPolicy -eq $true)
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("SuperUserAlias", `
                                                        "SuperReaderAlias", `
                                                        "SetWebAppPolicy")
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("SuperUserAlias", `
                                                        "SuperReaderAlias")
    }
}

Export-ModuleMember -Function *-TargetResource
