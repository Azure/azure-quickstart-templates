<#
.EXAMPLE
    This example creates a state service application in the local farm
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
            SPStateServiceApp StateServiceApp
            {
                Name                 = "State Service Application"
                DatabaseName         = "SP_State"
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
