# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for provisioning and managing the Project Server
service application in SharePoint Server 2016 or 2019.

To create a Project Server site the following DSC resources can
be used to create the site and enable the feature.

    SPSite PWASite
    {
        Url                      = "http://projects.contoso.com"
        OwnerAlias               = "CONTOSO\ExampleUser"
        HostHeaderWebApplication = "http://spsites.contoso.com"
        Name                     = "PWA Site"
        Template                 = "PWA#0"
        PsDscRunAsCredential     = $SetupAccount
    }

    SPFeature PWASiteFeature
    {
        Name                 = "PWASITE"
        Url                  = "http://projects.contoso.com"
        FeatureScope         = "Site"
        PsDscRunAsCredential = $SetupAccount
        DependsOn            = "[SPSite]PWASite"
    }
