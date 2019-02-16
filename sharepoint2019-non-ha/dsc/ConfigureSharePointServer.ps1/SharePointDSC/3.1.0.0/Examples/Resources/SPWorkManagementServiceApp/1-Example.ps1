<#
.EXAMPLE
    This example creates a new work management service app in the local farm
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
            SPWorkManagementServiceApp WorkManagementServiceApp
            {
                Name                   = "Work Management Service Application"
                ApplicationPool        = "SharePoint web services"
                MinimumTimeBetweenEwsSyncSubscriptionSearches = 10
                PsDscRunAsCredential   = $SetupAccount
            }
        }
    }
