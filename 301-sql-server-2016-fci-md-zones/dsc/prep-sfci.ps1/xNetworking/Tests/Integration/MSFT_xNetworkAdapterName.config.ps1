$realAdapter = (Get-NetAdapter -Physical | Select-Object -First 1)
$TestAdapter = [PSObject]@{
    Name                    = $realAdapter.Name
    MacAddress              = $realAdapter.MacAddress
}


configuration MSFT_xNetworkAdapterName_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xNetworkAdapterName Integration_Test {
            Name                    = $TestAdapter.Name
            MacAddress              = $TestAdapter.MacAddress
        }
    }
}
