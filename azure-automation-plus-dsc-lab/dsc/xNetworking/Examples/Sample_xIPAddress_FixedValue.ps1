configuration Sample_xIPAddress_FixedValue
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DscResource -Module xNetworking

    Node $NodeName
    {
        xIPAddress NewIPAddress
        {
            IPAddress      = "2001:4898:200:7:6c71:a102:ebd8:f482"
            InterfaceAlias = "Ethernet"
            SubnetMask     = 24
            AddressFamily  = "IPV6"
        }
    }
}