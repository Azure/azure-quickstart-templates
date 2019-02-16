<#
.EXAMPLE
    This example shows how to configure the AppCatalog in the farm
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
            SPAppCatalog MainAppCatalog
            {
                SiteUrl              = "https://content.sharepoint.contoso.com/sites/AppCatalog"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
