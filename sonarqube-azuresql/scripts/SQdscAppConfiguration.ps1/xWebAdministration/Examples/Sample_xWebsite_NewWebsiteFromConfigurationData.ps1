Configuration Sample_xWebsite_FromConfigurationData
{
    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    # Dynamically find the applicable nodes from configuration data
    Node $AllNodes.where{$_.Role -eq 'Web'}.NodeName
    {
        # Install the IIS role
        WindowsFeature IIS
        {
            Ensure          = 'Present'
            Name            = 'Web-Server'
        }

        # Install the ASP .NET 4.5 role
        WindowsFeature AspNet45
        {
            Ensure          = 'Present'
            Name            = 'Web-Asp-Net45'
        }

        # Stop an existing website (set up in Sample_xWebsite_Default)
        xWebsite DefaultSite 
        {
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            State           = 'Stopped'
            PhysicalPath    = $Node.DefaultWebSitePath
            DependsOn       = '[WindowsFeature]IIS'
        }

        # Copy the website content
        File WebContent
        {
            Ensure          = 'Present'
            SourcePath      = $Node.SourcePath
            DestinationPath = $Node.DestinationPath
            Recurse         = $true
            Type            = 'Directory'
            DependsOn       = '[WindowsFeature]AspNet45'
        }       

        # Create a new website
        xWebsite BakeryWebSite 
        {
            Ensure          = 'Present'
            Name            = $Node.WebsiteName
            State           = 'Started'
            PhysicalPath    = $Node.DestinationPath
            DependsOn       = '[File]WebContent'
        }
    }
}

