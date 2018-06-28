#requires -Version 1

@{
    AllNodes = @(
        @{
            NodeName                    = 'LocalHost'
            PSDscAllowPlainTextPassword = $true
            Website                     = 'WebsiteForSSLSettings'
            ApplicationPool             = 'DefaultAppPool'
            PhysicalPath                = 'C:\inetpub\wwwroot'
            HTTPSProtocol               = 'https'
            HTTPSPort                   = '443'
            HTTPSHostname               = 'https.website'
            CertificateStoreName        = 'MY'
            SslFlags                    = '1'
            Bindings                    = @('Ssl')
        }
    )
}
