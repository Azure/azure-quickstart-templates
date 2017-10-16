$DnsClientGlobalSetting = @{
    SuffixSearchList             = 'contoso.com'
    UseDevolution                = $True
    DevolutionLevel              = 2
}

Configuration MSFT_xDnsClientGlobalSetting_Config {
    Import-DscResource -ModuleName xNetworking
    node localhost {
        xDnsClientGlobalSetting Integration_Test {
            IsSingleInstance     = 'Yes'
            SuffixSearchList     = $DnsClientGlobalSetting.SuffixSearchList
            UseDevolution        = $DnsClientGlobalSetting.UseDevolution
            DevolutionLevel      = $DnsClientGlobalSetting.DevolutionLevel
        }
    }
}
