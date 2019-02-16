function Get-TargetResource()
{
    [CmdletBinding()]
    [OutputType([System.Collections.HashTable])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RemoteWebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LocalWebAppUrl,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting remote farm trust '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $returnValue = @{
            Name = $params.Name
            RemoteWebAppUrl = $params.RemoteWebAppUrl
            LocalWebAppUrl = $params.LocalWebAppUrl
            Ensure = "Absent"
            InstallAccount = $params.InstallAccount
        }

        $issuer = Get-SPTrustedSecurityTokenIssuer -Identity $params.Name `
                                                   -ErrorAction SilentlyContinue
        if ($null -eq $issuer)
        {
            return $returnValue
        }
        $rootAuthority = Get-SPTrustedRootAuthority -Identity $params.Name `
                                                    -ErrorAction SilentlyContinue
        if ($null -eq $rootAuthority)
        {
            return $returnValue
        }
        $realm = $issuer.NameId.Split("@")
        $site = Get-SPSite -Identity $params.LocalWebAppUrl
        $serviceContext = Get-SPServiceContext -Site $site
        $currentRealm = Get-SPAuthenticationRealm -ServiceContext $serviceContext

        if ($realm[1] -ne $currentRealm)
        {
            return $returnValue
        }
        $returnValue.Ensure = "Present"
        return $returnValue
    }
    return $result
}

function Set-TargetResource()
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RemoteWebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LocalWebAppUrl,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting remote farm trust '$Name'"

    if ($Ensure -eq "Present")
    {
        Write-Verbose -Message "Adding remote farm trust '$Name'"

        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            $remoteWebApp = $params.RemoteWebAppUrl.TrimEnd('/')

            $issuer = Get-SPTrustedSecurityTokenIssuer -Identity $params.Name `
                                                       -ErrorAction SilentlyContinue
            if ($null -eq $issuer)
            {
                $endpoint = "$remoteWebApp/_layouts/15/metadata/json/1"
                $issuer = New-SPTrustedSecurityTokenIssuer -Name $params.Name `
                                                           -IsTrustBroker:$false `
                                                           -MetadataEndpoint $endpoint `
                                                           -Confirm:$false
            }

            $rootAuthority = Get-SPTrustedRootAuthority -Identity $params.Name `
                                                        -ErrorAction SilentlyContinue
            if ($null -eq $rootAuthority)
            {
                $endpoint = "$remoteWebApp/_layouts/15/metadata/json/1/rootcertificate"
                New-SPTrustedRootAuthority -Name $params.Name `
                                           -MetadataEndPoint $endpoint `
                                           -Confirm:$false
            }
            $realm = $issuer.NameId.Split("@")
            $site = Get-SPSite -Identity $params.LocalWebAppUrl
            $serviceContext = Get-SPServiceContext -Site $site
            $currentRealm = Get-SPAuthenticationRealm -ServiceContext $serviceContext `
                                                      -ErrorAction SilentlyContinue

            if ($realm[1] -ne $currentRealm)
            {
                Set-SPAuthenticationRealm -ServiceContext $serviceContext -Realm $realm[1]
            }

            $appPrincipal = Get-SPAppPrincipal -Site $params.LocalWebAppUrl `
                                               -NameIdentifier $issuer.NameId

            Set-SPAppPrincipalPermission -Site $params.LocalWebAppUrl `
                                         -AppPrincipal $appPrincipal `
                                         -Scope SiteCollection `
                                         -Right FullControl
        }
    }

    if ($Ensure -eq "Absent")
    {
        Write-Verbose -Message "Removing remote farm trust '$Name'"

        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            $remoteWebApp = $params.RemoteWebAppUrl.TrimEnd('/')

            $issuer = Get-SPTrustedSecurityTokenIssuer -Identity $params.Name `
                                                       -ErrorAction SilentlyContinue
            if ($null -ne $issuer)
            {
                $appPrincipal = Get-SPAppPrincipal -Site $params.LocalWebAppUrl `
                                                   -NameIdentifier $issuer.NameId
                Remove-SPAppPrincipalPermission -Site $params.LocalWebAppUrl `
                                                -AppPrincipal $appPrincipal `
                                                -Scope SiteCollection `
                                                -Confirm:$false
            }

            Get-SPTrustedRootAuthority -Identity $params.Name `
                                       -ErrorAction SilentlyContinue `
                                       | Remove-SPTrustedRootAuthority -Confirm:$false
            if ($null -ne $issuer)
            {
                $issuer | Remove-SPTrustedSecurityTokenIssuer -Confirm:$false
            }
        }
    }
}

function Test-TargetResource()
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RemoteWebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LocalWebAppUrl,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String] $Ensure = "Present",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing remote farm trust '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
