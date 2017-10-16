configuration Sample_xIPAddress_StaticIP_Parameterized
{
    param
    (

        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [string]$IPAddress,

        [Parameter(Mandatory)]
        [string]$InterfaceAlias,

        [int]$PrefixLength = 16,

        [ValidateSet("IPv4","IPv6")]
        [string]$AddressFamily = 'IPv4'
    )

    Import-DscResource -Module xNetworking

    Node $NodeName
    {
        xDhcpClient DisabledDhcpClient
        {
            State          = 'Disabled'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = $AddressFamily
        }

        xIPAddress NewIPAddress
        {
            IPAddress      = $IPAddress
            InterfaceAlias = $InterfaceAlias
            PrefixLength   = $PrefixLength
            AddressFamily  = $AddressFamily
        }
    }
}
