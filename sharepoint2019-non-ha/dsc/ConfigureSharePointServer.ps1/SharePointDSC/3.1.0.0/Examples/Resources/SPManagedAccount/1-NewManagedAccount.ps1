<#
.EXAMPLE
    This example shows how to create a new managed account in a local farm.
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
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
