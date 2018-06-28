#requires -Version 4
configuration MSFT_xWebApplication_Present
{
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName
    {  
        xWebApplication WebApplication
        {
            Website = $Node.Website
            Ensure = 'Present'
            Name = $Node.WebApplication
            PhysicalPath = $Node.PhysicalPath
            WebAppPool = $Node.ApplicationPool
            ApplicationType = $Node.ApplicationType
            AuthenticationInfo = MSFT_xWebApplicationAuthenticationInformation
                {
                    Anonymous = $Node.AuthenticationInfoAnonymous
                    Basic     = $Node.AuthenticationInfoBasic
                    Digest    = $Node.AuthenticationInfoDigest
                    Windows   = $Node.AuthenticationInfoWindows
                }
            PreloadEnabled = $Node.PreloadEnabled
            ServiceAutoStartEnabled = $Node.ServiceAutoStartEnabled
            ServiceAutoStartProvider = $Node.ServiceAutoStartProvider
            SslFlags = $Node.WebApplicationSslFlags
        }
    }
}

configuration MSFT_xWebApplication_Absent
{
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName 
    {  
        xWebApplication WebApplication
        {
            Website = $Node.Website
            Ensure = 'Absent'
            Name = $Node.WebApplication
            PhysicalPath = $Node.PhysicalPath
            WebAppPool = $Node.ApplicationPool
        }
    }
}
