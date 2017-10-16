$TestDisableIPv4 = [PSObject]@{
    InterfaceAlias          = 'xNetworkingLBA'
    ComponentId             = 'ms_tcpip'
    State                   = 'Disabled'
}

configuration MSFT_xNetAdapterBinding_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xNetAdapterBinding Integration_Test {
            InterfaceAlias          = $TestDisableIPv4.InterfaceAlias
            ComponentId             = $TestDisableIPv4.ComponentId
            State                   = $TestDisableIPv4.State
        }
    }
}
