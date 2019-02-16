<#
.EXAMPLE
    This example deploys a usage application to the local farm
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
            SPUsageApplication UsageApplication 
            {
                Name                  = "Usage Service Application"
                DatabaseName          = "SP_Usage"
                UsageLogCutTime       = 5
                UsageLogLocation      = "L:\UsageLogs"
                UsageLogMaxFileSizeKB = 1024
                Ensure                = "Present"
                InstallAccount        = $SetupAccount
            }
        }
    }
