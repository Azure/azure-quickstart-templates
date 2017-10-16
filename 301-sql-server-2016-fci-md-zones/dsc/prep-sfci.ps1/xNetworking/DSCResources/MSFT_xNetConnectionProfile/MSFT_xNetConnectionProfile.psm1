data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
    GettingNetConnectionProfile = Getting NetConnectionProfile from interface '{0}'.
    TestIPv4Connectivity        = IPv4Connectivity '{0}' does not match set IPv4Connectivity '{1}'
    TestIPv6Connectivity        = IPv6Connectivity '{0}' does not match set IPv6Connectivity '{1}'
    TestNetworkCategory         = NetworkCategory '{0}' does not match set NetworkCategory '{1}'
    SetNetConnectionProfile     = Setting NetConnectionProfile on interface '{0}'
'@
}


function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Position = 0, Mandatory = $true)]
        [string] $InterfaceAlias
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.GettingNetConnectionProfile) -f $InterfaceAlias
    ) -join '')

    $result = Get-NetConnectionProfile -InterfaceAlias $InterfaceAlias

    return @{
        InterfaceAlias   = $result.InterfaceAlias
        NetworkCategory  = $result.NetworkCategory
        IPv4Connectivity = $result.IPv4Connectivity
        IPv6Connectivity = $result.IPv6Connectivity
    }
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory = $true)]
        [string] $InterfaceAlias,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string] $IPv4Connectivity,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string] $IPv6Connectivity,

        [ValidateSet('Public', 'Private')]
        [string] $NetworkCategory
    )

    Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
        $($LocalizedData.SetNetConnectionProfile) -f $InterfaceAlias
    ) -join '')

    Set-NetConnectionProfile @PSBoundParameters
}


function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string] $InterfaceAlias,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string] $IPv4Connectivity,

        [ValidateSet('Disconnected', 'NoTraffic', 'Subnet', 'LocalNetwork', 'Internet')]
        [string] $IPv6Connectivity,

        [ValidateSet('Public', 'Private')]
        [string] $NetworkCategory
    )

    $current = Get-TargetResource -InterfaceAlias $InterfaceAlias

    if ($IPv4Connectivity -ne $current.IPv4Connectivity)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestIPv4Connectivity) -f $IPv4Connectivity, $current.IPv4Connectivity
        ) -join '')

        return $false
    }

    if ($IPv6Connectivity -ne $current.IPv6Connectivity)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestIPv6Connectivity) -f $IPv6Connectivity, $current.IPv6Connectivity
        ) -join '')

        return $false
    }

    if ($NetworkCategory -ne $current.NetworkCategory)
    {
        Write-Verbose -Message ( @( "$($MyInvocation.MyCommand): "
            $($LocalizedData.TestNetworkCategory) -f $NetworkCategory, $current.NetworkCategory
        ) -join '')

        return $false
    }

    return $true
}
