configuration Sample_xWebsite_NewWebsite
{
    param
    (
        # Target nodes to apply the configuration
        [String[]] $NodeName = 'localhost',

        # Name of the website to create
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $WebSiteName,

        # Source Path for Website content
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $SourcePath,

        # Destination path for Website content
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DestinationPath
    )

    # Import the module that defines custom resources
    Import-DscResource -Module xWebAdministration, PSDesiredStateConfiguration

    Node $NodeName
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

        # Stop the default website
        xWebsite DefaultSite 
        {
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            State           = 'Stopped'
            PhysicalPath    = 'C:\inetpub\wwwroot'
            DependsOn       = '[WindowsFeature]IIS'
        }

        # Copy the website content
        File WebContent
        {
            Ensure          = 'Present'
            SourcePath      = $SourcePath
            DestinationPath = $DestinationPath
            Recurse         = $true
            Type            = 'Directory'
            DependsOn       = '[WindowsFeature]AspNet45'
        }       

        # Create the new Website
        xWebsite NewWebsite
        {
            Ensure          = 'Present'
            Name            = $WebSiteName
            State           = 'Started'
            PhysicalPath    = $DestinationPath
            DependsOn       = '[File]WebContent'
        }
    }
}

