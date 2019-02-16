<#
.EXAMPLE
    This example sets the branding for the suite bar of a given
    Web Application in SharePoint 2016/2019.
#>

    Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPWebAppSuiteBar SP2016Branding
            {
                WebAppUrl                               = "https://intranet.sharepoint.contoso.com"
                SuiteNavBrandingLogoNavigationUrl       = "http://sites.sharepoint.com"
                SuiteNavBrandingLogoTitle               = "This is my logo"
                SuiteNavBrandingLogoUrl                 = "http://sites.sharepoint.com/images/logo.gif"
                SuiteNavBrandingText                    = "SharePointDSC WebApp"
                PsDscRunAsCredential                    = $SetupAccount
            }
        }
    }
