<#
.EXAMPLE
    This example sets the branding for the suite bar of a given
    Web Application in SharePoint 2013.
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
            SPWebAppSuiteBar SP2013Branding
            {
                WebAppUrl                               = "https://intranet.sharepoint.contoso.com"
                SuiteBarBrandingElementHtml             = "<div>SharePointDSC WebApp</div>"
                PsDscRunAsCredential                    = $SetupAccount
            }
        }
    }
