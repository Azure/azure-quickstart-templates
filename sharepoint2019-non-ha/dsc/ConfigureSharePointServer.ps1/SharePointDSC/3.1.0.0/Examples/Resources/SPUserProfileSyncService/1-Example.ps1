<#
.EXAMPLE
    This example provisions the user profile sync service to the local server
#>

    Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $FarmAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPUserProfileSyncService UserProfileSyncService
            {
                UserProfileServiceAppName   = "User Profile Service Application"
                Ensure                      = "Present"
                FarmAccount                 = $FarmAccount
                RunOnlyWhenWriteable        = $true
                InstallAccount              = $SetupAccount
            }
        }
    }
