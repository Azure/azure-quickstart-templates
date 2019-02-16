<#
.EXAMPLE
    This example removes the specific performance point service app from the local
    farm. The ApplicationPool parameter is still mandatory but it is not used, so
    the value can be anything. 
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
                ApplicationPool = "n/a"
                Ensure = "Absent"
                InstallAccount  = $SetupAccount
            }
        }
    }
