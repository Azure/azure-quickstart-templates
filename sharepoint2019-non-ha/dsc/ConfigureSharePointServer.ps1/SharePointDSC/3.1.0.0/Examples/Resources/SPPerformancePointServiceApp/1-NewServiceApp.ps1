<#
.EXAMPLE
    This example creates a new performance point service app in the local farm.
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
            SPPerformancePointServiceApp PerformancePoint
            {
                Name = "Performance Point Service Application"
                ApplicationPool = "SharePoint Web Services"
                InstallAccount  = $SetupAccount
            }
        }
    }
