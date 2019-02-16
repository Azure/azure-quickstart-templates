<#
.EXAMPLE
    This example removes a search service app in the local farm. The ApplicationPool
    parameter is still required but is not actually used, so its value does not matter.
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
            SPSearchServiceApp SearchServiceApp
            {
                Name                  = "Search Service Application"
                Ensure                = "Absent"
                ApplicationPool       = "n/a"
                PsDscRunAsCredential  = $SetupAccount
            }
        }
    }
