configuration MSFT_xRoute_Add_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xRoute Integration_Test {
            InterfaceAlias          = $TestRoute.InterfaceAlias
            AddressFamily           = $TestRoute.AddressFamily
            DestinationPrefix       = $TestRoute.DestinationPrefix
            NextHop                 = $TestRoute.NextHop
            Ensure                  = 'Present'
            RouteMetric             = $TestRoute.RouteMetric
            Publish                 = $TestRoute.Publish
        }
    }
}
