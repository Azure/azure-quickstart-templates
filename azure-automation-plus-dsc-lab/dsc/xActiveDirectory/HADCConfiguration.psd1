@{
    AllNodes = @(

        @{
            Nodename = "sva-dsc1"
            Role = "Primary DC"
            DomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true
        RetryCount = 20 
        RetryIntervalSec = 30 
        },

        @{
            Nodename = "sva-dsc2"
            Role = "Replica DC"
            DomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true
        RetryCount = 20 
        RetryIntervalSec = 30 
        }
    )
}

