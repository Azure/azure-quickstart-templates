<#
.EXAMPLE
    This example shows how to create a Search Authoritative Page
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
            SPSearchAuthoritativePage AuthoratativePage
            {
                ServiceAppName       = "Search Service Application"
                Path                 = "http://site.sharepoint.com/Pages/authoritative.aspx"
                Action               = "Authoratative"
                Level                = 0.0
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
