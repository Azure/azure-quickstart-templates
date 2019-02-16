<#
.EXAMPLE
    This example shows how to create a Search Demoted Page
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
                Path                 = "http://site.sharepoint.com/Pages/demoted.aspx"
                Action               = "Demoted"
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
