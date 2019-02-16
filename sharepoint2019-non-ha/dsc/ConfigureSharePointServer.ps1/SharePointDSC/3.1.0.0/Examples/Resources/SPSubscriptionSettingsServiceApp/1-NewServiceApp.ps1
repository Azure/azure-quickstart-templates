<#
.EXAMPLE
    This example creates a new subscription settings service app in the local farm.
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
            SPSubscriptionSettingsServiceApp SubscriptionSettingsServiceApp
            {
                Name                 = "Subscription Settings Service Application"
                ApplicationPool      = "SharePoint web services"
                DatabaseServer       = "SQL01.contoso.com"
                DatabaseName         = "SP_SubscriptionSettings"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
