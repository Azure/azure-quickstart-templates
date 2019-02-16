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
            SPAppStoreSettings EnableAppStores
            {
                WebAppUrl            = "https://sharepoint.contoso.com"
                AllowAppPurchases    = $true
                AllowAppsForOffice   = $true
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
