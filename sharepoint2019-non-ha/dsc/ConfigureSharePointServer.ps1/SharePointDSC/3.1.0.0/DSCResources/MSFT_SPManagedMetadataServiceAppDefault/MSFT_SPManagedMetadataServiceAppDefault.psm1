function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DefaultSiteCollectionProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DefaultKeywordProxyName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting the default site collection and keyword term store settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
        -Arguments $PSBoundParameters `
        -ScriptBlock {

        $params = $args[0]

        $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue

        if ($null -eq $serviceAppProxies)
        {
            throw "There are no Managed Metadata Service Application Proxy available in the farm"
        }

        $serviceAppProxies = $serviceAppProxies | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplicationProxy"
        }

        if ($null -eq $serviceAppProxies)
        {
            throw "There are no Managed Metadata Service Application Proxy available in the farm"
        }

        $defaultSiteCollectionProxyIsSet = $false
        $defaultKeywordProxyIsSet = $false

        $defaultSiteCollectionProxy = $null
        $defaultKeywordProxy = $null

        foreach ($serviceAppProxy in $serviceAppProxies)
        {
            if ($serviceAppProxy.Properties["IsDefaultSiteCollectionTaxonomy"] -eq $true)
            {
                if ($defaultSiteCollectionProxyIsSet -eq $false)
                {
                    $defaultSiteCollectionProxy = $serviceAppProxy.Name
                    $defaultSiteCollectionProxyIsSet = $true
                }
                else
                {
                    $defaultSiteCollectionProxy = $null
                }
            }
            if ($serviceAppProxy.Properties["IsDefaultKeywordTaxonomy"] -eq $true)
            {
                if ($defaultKeywordProxyIsSet -eq $false)
                {
                    $defaultKeywordProxy = $serviceAppProxy.Name
                    $defaultKeywordProxyIsSet = $true
                }
                else
                {
                    $defaultKeywordProxy = $null
                }
            }
        }

        return @{
            IsSingleInstance               = $params.IsSingleInstance
            DefaultSiteCollectionProxyName = $defaultSiteCollectionProxy
            DefaultKeywordProxyName        = $defaultKeywordProxy
            InstallAccount                 = $params.InstallAccount
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
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DefaultSiteCollectionProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DefaultKeywordProxyName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting the default site collection and keyword term store settings"

    $result = Get-TargetResource @PSBoundParameters

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
        -Arguments $PSBoundParameters `
        -ScriptBlock {

        $params = $args[0]

        $serviceAppProxies = Get-SPServiceApplicationProxy -ErrorAction SilentlyContinue

        $serviceAppProxies = $serviceAppProxies | Where-Object -FilterScript {
            $_.GetType().FullName -eq "Microsoft.SharePoint.Taxonomy.MetadataWebServiceApplicationProxy"
        }

        foreach ($serviceAppProxy in $serviceAppProxies)
        {
            $proxyName = $serviceAppProxy.Name

            $serviceAppProxy.Properties["IsDefaultKeywordTaxonomy"] = $false
            $serviceAppProxy.Properties["IsDefaultSiteCollectionTaxonomy"] = $false

            if ($proxyName -eq $params.DefaultKeywordProxyName)
            {
                $serviceAppProxy.Properties["IsDefaultKeywordTaxonomy"] = $true
            }

            if ($proxyName -eq $params.DefaultSiteCollectionProxyName)
            {
                $serviceAppProxy.Properties["IsDefaultSiteCollectionTaxonomy"] = $true
            }

            $serviceAppProxy.Update()
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
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DefaultSiteCollectionProxyName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DefaultKeywordProxyName,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing the default site collection and keyword term store settings"

    $valuesToCheck = @(
        "DefaultSiteCollectionProxyName",
        "DefaultKeywordProxyName"
    )

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $valuesToCheck
}

Export-ModuleMember -Function *-TargetResource
