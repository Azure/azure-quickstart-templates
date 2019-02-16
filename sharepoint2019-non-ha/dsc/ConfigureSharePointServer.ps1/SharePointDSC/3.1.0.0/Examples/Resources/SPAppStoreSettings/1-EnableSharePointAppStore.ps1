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
            SPAppStoreSettings EnableSharePointAppStore
            {
                WebAppUrl            = "https://sharepoint.contoso.com"
                AllowAppPurchases    = $true
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
