<#
.EXAMPLE
    This example creates a new search service app in the local farm
#>

    Configuration Example
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SearchAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPSearchServiceSettings SearchServiceSettings
            {
                IsSingleInstance      = "Yes"
                PerformanceLevel      = "Maximum"
                ContactEmail          = "sharepoint@contoso.com"
                WindowsServiceAccount = $SearchAccount
                PsDscRunAsCredential  = $SetupAccount
            }
        }
    }
