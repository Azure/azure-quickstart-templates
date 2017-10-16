configuration Sample_xNetConnectionProfile
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

    Import-DscResource -Module xNetworking

    Node $NodeName
    {
        xNetConnectionProfile Integration_Test
        {
            InterfaceAlias   = $InterfaceAlias
            NetworkCategory  = $NetworkCategory
            IPv4Connectivity = $IPv4Connectivity
            IPv6Connectivity = $IPv6Connectivity
        }
    }
}
