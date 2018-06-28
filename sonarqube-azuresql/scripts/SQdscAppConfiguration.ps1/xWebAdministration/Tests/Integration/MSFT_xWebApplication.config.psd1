#requires -Version 1
@{
    AllNodes = @(
        @{
            NodeName                    = 'LocalHost'
            PSDscAllowPlainTextPassword = $true
            Website                     = 'WebsiteForWebApplication'
            WebApplication              = 'WebApplication'
            ApplicationType             = 'WebsiteApplicationType'
            ApplicationPool             = 'DefaultAppPool'
            PhysicalPath                = 'C:\inetpub\wwwroot'
            PreloadEnabled              = $true
            ServiceAutoStartEnabled     = $true
            ServiceAutoStartProvider    = 'WebsiteServiceAutoStartProvider'
            AuthenticationInfoAnonymous = $true
            AuthenticationInfoBasic     = $false
            AuthenticationInfoDigest    = $false
            AuthenticationInfoWindows   = $true
            HTTPSProtocol               = 'https'
            HTTPSPort                   = '443'
            HTTPSHostname               = 'https.website'
            CertificateStoreName        = 'MY'
            SslFlags                    = '1'
            WebApplicationSslFlags      = @('Ssl')
        }
    )
}
