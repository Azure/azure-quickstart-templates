<#
.EXAMPLE
    This example shows how to configure the retention period for a Diagnostics Provider.
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
            SPDiagnosticsProvider BlockingQueryProvider
            {
                Ensure               = "Present"
                Name                 = "job-diagnostics-blocking-query-provider"
                MaxTotalSizeInBytes  = 10000000000000
                Retention            = 14
                Enabled              = $true
                PSDscRunAsCredential = $SetupAccount
            }
        }
    }
