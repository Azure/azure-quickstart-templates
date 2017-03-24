configuration CookieApp
{
    Param ($content = 'No content', $sub)

    Import-DscResource -Module xWebAdministration

    # Install the IIS role
    WindowsFeature IIS
    {  
        Ensure          = “Present”  
        Name            = “Web-Server”  
    }  
  
    # Install the ASP .NET 4.5 role 
    WindowsFeature AspNet45  
    {  
        Ensure          = “Present”
        Name            = “Web-Asp-Net45”
    }  
  
    # Stop the default website 
    xWebsite DefaultSite  
    {  
        Ensure          = “Present”
        Name            = “Default Web Site”
        State           = “Stopped”
        PhysicalPath    = “C:\inetpub\wwwroot”
        DependsOn       = “[WindowsFeature]IIS”
    }
  
    # Author website content - ROOT
    File RootWebContent
    {  
        Ensure          = “Present”
        MatchSource     = $true
        Contents      = ("Root of " + $content + " | " + $env:COMPUTERNAME)
        Force = $true
        DestinationPath = “C:\inetpub\CookieWebApp\index.html”
        Recurse         = $true  
        Type            = “File”  
        DependsOn       = “[WindowsFeature]AspNet45”  
    }

    # Author website content - SUB
    File SubWebContent
    {  
        Ensure          = “Present”
        MatchSource     = $true
        Contents      = ("Sub of " + $content + " | " + $env:COMPUTERNAME)
        Force = $true
        DestinationPath = ("C:\inetpub\CookieWebApp\" + $sub + "\index.html")
        Recurse         = $true
        Type            = “File”  
        DependsOn       = “[WindowsFeature]AspNet45”  
    }

    # Create a new website 
    xWebsite CookieWebApp
    {  
        Ensure          = “Present”  
        Name            = “CookieWebApp” 
        State           = “Started”  
        PhysicalPath    = “C:\inetpub\CookieWebApp”  
        DependsOn       = “[File]RootWebContent”  
    }
}