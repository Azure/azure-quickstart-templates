<#
.EXAMPLE
    This example shows how to ensure that the Business Data Connectivity Service 
    is not running on the local server. 
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
            SPServiceInstance StopBCSServiceInstance
            {
                Name           = "Business Data Connectivity Service"
                Ensure         = "Absent"
                InstallAccount = $SetupAccount
            }
        }
    }
