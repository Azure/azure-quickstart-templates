#requires -Version 4

configuration MSFT_xWebsite_Present_Started
{
    param(
        
        [Parameter(Mandatory = $true)]
        [String] $CertificateThumbprint
    
    )

    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName
    {  
        xWebsite Website
        {
            Name = $Node.Website
            Ensure = 'Present'
            ApplicationType = $Node.ApplicationType
            ApplicationPool = $Node.ApplicationPool
            AuthenticationInfo = `
                MSFT_xWebAuthenticationInformation
                {
                    Anonymous = $Node.AuthenticationInfoAnonymous
                    Basic     = $Node.AuthenticationInfoBasic
                    Digest    = $Node.AuthenticationInfoDigest
                    Windows   = $Node.AuthenticationInfoWindows
                }
            BindingInfo = @(MSFT_xWebBindingInformation
                {
                    Protocol              = $Node.HTTPProtocol
                    Port                  = $Node.HTTPPort
                    IPAddress             = '*'
                    Hostname              = $Node.HTTP1Hostname
                }
                MSFT_xWebBindingInformation
                {
                    Protocol              = $Node.HTTPProtocol
                    Port                  = $Node.HTTPPort
                    IPAddress             = '*'
                    Hostname              = $Node.HTTP2Hostname
                }
                MSFT_xWebBindingInformation
                {
                    Protocol              = $Node.HTTPSProtocol
                    Port                  = $Node.HTTPSPort
                    IPAddress             = '*'
                    Hostname              = $Node.HTTPSHostname
                    CertificateThumbprint = $CertificateThumbprint
                    CertificateStoreName  = $Node.CertificateStoreName
                    SslFlags              = $Node.SslFlags
                })
            DefaultPage = $Node.DefaultPage
            EnabledProtocols = $Node.EnabledProtocols
            PhysicalPath = $Node.PhysicalPath
            PreloadEnabled = $Node.PreloadEnabled
            ServiceAutoStartEnabled = $Node.ServiceAutoStartEnabled
            ServiceAutoStartProvider = $Node.ServiceAutoStartProvider
            State = 'Started'
        }
    }
}

configuration MSFT_xWebsite_Present_Stopped
{
    param(
        
        [Parameter(Mandatory = $true)]
        [String]$CertificateThumbprint
    
    )

    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName 
    {  
        xWebsite Website
        {
            Name = $Node.Website
            Ensure = 'Present'
            ApplicationType = $Node.ApplicationType
            ApplicationPool = $Node.ApplicationPool
            AuthenticationInfo = `
                MSFT_xWebAuthenticationInformation
                {
                    Anonymous = $Node.AuthenticationInfoAnonymous
                    Basic     = $Node.AuthenticationInfoBasic
                    Digest    = $Node.AuthenticationInfoDigest
                    Windows   = $Node.AuthenticationInfoWindows
                }
            BindingInfo = @(
                MSFT_xWebBindingInformation
                {
                    Protocol              = $Node.HTTPProtocol
                    Port                  = $Node.HTTPPort
                    IPAddress             = '*'
                    Hostname              = $Node.HTTP1Hostname
                }
                MSFT_xWebBindingInformation
                {
                    Protocol              = $Node.HTTPProtocol
                    Port                  = $Node.HTTPPort
                    IPAddress             = '*'
                    Hostname              = $Node.HTTP2Hostname
                }
                MSFT_xWebBindingInformation
                {
                    Protocol              = $Node.HTTPSProtocol
                    Port                  = $Node.HTTPSPort
                    IPAddress             = '*'
                    Hostname              = $Node.HTTPSHostname
                    CertificateThumbprint = $CertificateThumbprint
                    CertificateStoreName  = $Node.CertificateStoreName
                    SslFlags              = $Node.SslFlags
            })
            DefaultPage = $Node.DefaultPage
            EnabledProtocols = $Node.EnabledProtocols
            PhysicalPath = $Node.PhysicalPath
            PreloadEnabled = $Node.PreloadEnabled
            ServiceAutoStartEnabled = $Node.ServiceAutoStartEnabled
            ServiceAutoStartProvider = $Node.ServiceAutoStartProvider
            State = 'Stopped'
        }
    }
}

configuration MSFT_xWebsite_Absent
{
    Import-DscResource -ModuleName xWebAdministration

    Node $AllNodes.NodeName 
    {  
        xWebsite Website
        {
            Name = $Node.Website
            Ensure = 'Absent'
        }
    }
}
