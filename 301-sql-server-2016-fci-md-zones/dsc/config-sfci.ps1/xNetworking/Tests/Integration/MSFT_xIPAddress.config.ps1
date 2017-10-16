$TestIPAddress = [PSObject]@{
    InterfaceAlias          = 'xNetworkingLBA'
    AddressFamily           = 'IPv4'
    IPAddress               = '10.11.12.13'
    PrefixLength            = 16
}

configuration MSFT_xIPAddress_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xIPAddress Integration_Test {
            InterfaceAlias          = $TestIPAddress.InterfaceAlias
            AddressFamily           = $TestIPAddress.AddressFamily
            IPAddress               = $TestIPAddress.IPAddress
            PrefixLength            = $TestIPAddress.PrefixLength
        }
    }
}
