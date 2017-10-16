$TestDefaultGatewayAddress = [PSObject]@{
    InterfaceAlias          = 'xNetworkingLBA'
    AddressFamily           = 'IPv4'
    Address                 = '10.0.0.0'
}

configuration MSFT_xDefaultGatewayAddress_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xDefaultGatewayAddress Integration_Test {
            InterfaceAlias          = $TestDefaultGatewayAddress.InterfaceAlias
            AddressFamily           = $TestDefaultGatewayAddress.AddressFamily
            Address                 = $TestDefaultGatewayAddress.Address
        }
    }
}
