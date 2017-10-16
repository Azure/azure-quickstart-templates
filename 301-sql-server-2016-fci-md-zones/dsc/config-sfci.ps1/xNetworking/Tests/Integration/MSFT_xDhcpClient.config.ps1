$TestDhcpClient = [PSObject]@{
    InterfaceAlias          = 'xNetworkingLBA'
    AddressFamily           = 'IPv4'
    State                   = 'Enabled'
}

configuration MSFT_xDhcpClient_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xDhcpClient Integration_Test {
            InterfaceAlias          = $TestDhcpClient.InterfaceAlias
            AddressFamily           = $TestDhcpClient.AddressFamily
            State                   = $TestDhcpClient.State
        }
    }
}
