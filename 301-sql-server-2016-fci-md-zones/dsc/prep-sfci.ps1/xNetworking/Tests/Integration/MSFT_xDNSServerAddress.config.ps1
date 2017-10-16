$TestDNSServerAddress = [PSObject]@{
    InterfaceAlias          = 'xNetworkingLBA'
    AddressFamily           = 'IPv4'
    Address                 = '10.139.17.99'
    Validate                = $False
}

configuration MSFT_xDNSServerAddress_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xDNSServerAddress Integration_Test {
            InterfaceAlias          = $TestDNSServerAddress.InterfaceAlias
            AddressFamily           = $TestDNSServerAddress.AddressFamily
            Address                 = $TestDNSServerAddress.Address
            Validate                = $TestDNSServerAddress.Validate
        }
    }
}
