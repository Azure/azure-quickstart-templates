<#
.EXAMPLE
    This example shows how to apply site use and deletion settings to the specified web application
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
            SPWebAppSiteUseAndDeletion ConfigureSiteUseAndDeletion
            {
                WebAppUrl                                = "http://example.contoso.local"
                SendUnusedSiteCollectionNotifications    = $true
                UnusedSiteNotificationPeriod             = 90
                AutomaticallyDeleteUnusedSiteCollections = $true
                UnusedSiteNotificationsBeforeDeletion    = 24
                PsDscRunAsCredential                     = $SetupAccount
            }
        }
    }
