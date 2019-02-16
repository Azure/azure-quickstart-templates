<#
.EXAMPLE
    This example creates a new search service app in the local farm
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
                DatabaseName          = "SP_Search"
                ApplicationPool       = "SharePoint Service Applications"
                PsDscRunAsCredential  = $SetupAccount
            }
        }
    }
