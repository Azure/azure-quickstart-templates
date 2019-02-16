<#
.EXAMPLE
    This example shows how to use the local farm token to grant
    full control permission to the local farm to the
    user profile service app's sharing permission.
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
            $members = @()
            $members += MSFT_SPServiceAppSecurityEntry {
                                    Username     = "{LocalFarm}"
                                    AccessLevels = @("Full Control")
                                }
            SPServiceAppSecurity UserProfileServiceSecurity
            {
                ServiceAppName       = "User Profile Service Application"
                SecurityType         = "SharingPermissions"
                Members              = $members
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
