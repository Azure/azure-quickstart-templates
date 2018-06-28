#requires -Version 1

@{
    AllNodes = @(
        @{
            NodeName                    = 'LocalHost'
            PSDscAllowPlainTextPassword = $true
            Website                     = 'Website'
            ApplicationType             = 'WebsiteApplicationType'
            ApplicationPool             = 'DefaultAppPool'
            DefaultPage                 = 'Website.html'
            EnabledProtocols            = 'http'
            PhysicalPath                = 'C:\inetpub\wwwroot'
            PreloadEnabled              = $true
            ServiceAutoStartEnabled     = $true
            ServiceAutoStartProvider    = 'WebsiteServiceAutoStartProvider'
            AuthenticationInfoAnonymous = $true
            AuthenticationInfoBasic     = $false
            AuthenticationInfoDigest    = $false
            AuthenticationInfoWindows   = $true
            HTTPProtocol                = 'http'
            HTTPPort                    = '80'
            HTTP1Hostname               = 'http1.website'
            HTTP2Hostname               = 'http2.website'
            HTTPSProtocol               = 'https'
            HTTPSPort                   = '443'
            HTTPSHostname               = 'https.website'
            CertificateStoreName        = 'MY'
            SslFlags                    = '1'
        }
    )
}
