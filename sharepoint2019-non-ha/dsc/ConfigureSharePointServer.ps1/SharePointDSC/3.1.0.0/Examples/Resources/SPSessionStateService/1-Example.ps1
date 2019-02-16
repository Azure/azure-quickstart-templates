<#
.EXAMPLE
    This example creates a new session state service on the local farm.
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
            SPSessionStateService StateServiceApp
            {
                DatabaseName         = "SP_StateService"
                DatabaseServer       = "SQL.test.domain"
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
