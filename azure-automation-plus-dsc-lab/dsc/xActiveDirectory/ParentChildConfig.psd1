@{
    AllNodes = @(

        @{
            Nodename = "sva-dsc1"
            Role = "Parent DC"
            DomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true
        RetryCount = 50 
        RetryIntervalSec = 30 
        },

        @{
            Nodename = "sva-dsc2"
            Role = "Child DC"
            DomainName = "sva-dscchild"
            ParentDomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true    
        RetryCount = 50 
        RetryIntervalSec = 30        
        }
    )
}

