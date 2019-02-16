<#
.EXAMPLE
    This example creates a specific quota template in the local farm.
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
            SPQuotaTemplate TeamsiteTemplate
            {
                Name = "Teamsite"
                StorageMaxInMB = 1024
                StorageWarningInMB = 512
                MaximumUsagePointsSolutions = 1000
                WarningUsagePointsSolutions = 800
                Ensure = "Present"
            }
        }
    }
