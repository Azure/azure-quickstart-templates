configuration Sample_xIPAddress_FixedValue
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -Module xNetworking

    Node $NodeName
    {
        xDhcpClient DisabledDhcpClient
        {
            State          = 'Disabled'
            InterfaceAlias = "Ethernet"
            AddressFamily  = "IPv6"
        }

        xIPAddress NewIPAddress
        {
            IPAddress      = "2001:4898:200:7:6c71:a102:ebd8:f482"
            InterfaceAlias = "Ethernet"
            PrefixLength   = 24
            AddressFamily  = "IPV6"
        }
    }
}
