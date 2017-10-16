$TestDnsConnectionSuffix = [PSObject]@{
    InterfaceAlias                 = 'xNetworkingLBA'
    ConnectionSpecificSuffix       = 'contoso.com'
    RegisterThisConnectionsAddress = $true
    UseSuffixWhenRegistering       = $false
    Ensure                         = 'Present'
}

configuration MSFT_xDnsConnectionSuffix_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xDnsConnectionSuffix Integration_Test {
            InterfaceAlias                 = $TestDnsConnectionSuffix.InterfaceAlias
            ConnectionSpecificSuffix       = $TestDnsConnectionSuffix.ConnectionSpecificSuffix
            RegisterThisConnectionsAddress = $TestDnsConnectionSuffix.RegisterThisConnectionsAddress
            UseSuffixWhenRegistering       = $TestDnsConnectionSuffix.UseSuffixWhenRegistering
            Ensure                         = $TestDnsConnectionSuffix.Ensure
        }
    }
}
