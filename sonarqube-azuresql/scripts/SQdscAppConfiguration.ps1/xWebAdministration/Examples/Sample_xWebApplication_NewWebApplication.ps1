<#
.SYNOPSIS
    Create a new web application on the Default Web Site
.DESCRIPTION
    This example shows how to use the xWebApplication DSC resource to create a new web application.
#>
Configuration Sample_xWebApplication_NewWebApplication
{
    param
    (
        # Target nodes to apply the configuration
        [String[]] $NodeName = 'localhost',

        # Destination path for Website content
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPath
    )

    # Import the module that defines custom resources
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xWebAdministration

    Node $NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure                  = 'Present'
            Name                    = 'Web-Server'
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure                  = 'Present'
            Name                    = 'Web-Asp-Net45'
        }

        # Start the Default Web Site
        xWebsite DefaultSite 
        {
            Ensure                  = 'Present'
            Name                    = 'Default Web Site'
            State                   = 'Started'
            PhysicalPath            = 'C:\inetpub\wwwroot'
            DependsOn               = '[WindowsFeature]IIS'
        }

        # Create a new application pool for the application
        xWebAppPool SampleAppPool
        {
            Ensure                  = 'Present'
            Name                    = 'SampleAppPool'
        }

        # Clone the wwwroot folder to the destination
        File WebContent
        {
            Ensure                  = 'Present'
            SourcePath              = 'C:\inetpub\wwwroot'
            DestinationPath         = $DestinationPath
            Recurse                 = $true
            Type                    = 'Directory'
            DependsOn               = '[WindowsFeature]IIS'
        }

        # Create a new web application with Windows Authentication
        xWebApplication SampleApplication 
        {
            Ensure                  = 'Present'
            Name                    = 'SampleApplication'
            WebAppPool              = 'SampleAppPool'
            Website                 = 'Default Web Site'
            PreloadEnabled          = $true
            ServiceAutoStartEnabled = $true
            AuthenticationInfo      = MSFT_xWebApplicationAuthenticationInformation
            {
                Anonymous   = $false
                Basic       = $false
                Digest      = $false
                Windows     = $true
            }
            SslFlags                = ''
            PhysicalPath            = $DestinationPath
            DependsOn               = '[xWebsite]DefaultSite','[xWebAppPool]SampleAppPool'
        }
    }
}

