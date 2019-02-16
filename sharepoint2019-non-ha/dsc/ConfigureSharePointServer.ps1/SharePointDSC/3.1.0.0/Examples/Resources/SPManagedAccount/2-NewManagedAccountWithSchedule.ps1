<#
.EXAMPLE
    This example shows how to create a new managed account in a local farm, using
    the automatic password change schedule
#>

    Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $ManagedAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPManagedAccount NewManagedAccount
            {
                AccountName          = $ManagedAccount.UserName
                Account              = $ManagedAccount
                Ensure               = "Present"
                Schedule             = "monthly between 7 02:00:00 and 7 03:00:00" 
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
