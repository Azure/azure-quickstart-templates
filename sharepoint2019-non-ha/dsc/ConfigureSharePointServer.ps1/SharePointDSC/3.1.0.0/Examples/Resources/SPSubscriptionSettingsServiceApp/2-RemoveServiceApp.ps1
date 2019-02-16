<#
.EXAMPLE
    This example removes a subscription settings service app in the local farm.
    The ApplicationPool property is required, but is ignored when removing a 
    service app.
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
                ApplicationPool      = "n/a"
                PsDscRunAsCredential = $SetupAccount
                Ensure               = "Absent"
            }
        }
    }
