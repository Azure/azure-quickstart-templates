configuration Sample_xDnsServerAddress
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [string]$DnsServerAddress,

        [Parameter(Mandatory)]
        [string]$InterfaceAlias,

        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )

    Import-DscResource -Module xNetworking

    Node $NodeName
    {
        xDnsServerAddress DnsServerAddress
        {
            Address        = $DnsServerAddress
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }
    }
}