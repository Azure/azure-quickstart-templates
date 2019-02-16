<#
.EXAMPLE
    This example applies permissions for the user profile service application to limit
    access to specific features.
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
            SPUserProfileServiceAppPermissions UPAPermissions
            {
                ProxyName            = "User Profile Service Application Proxy"
                CreatePersonalSite   = @("DEMO\Group", "DEMO\User1")
                FollowAndEditProfile = @("Everyone")
                UseTagsAndNotes      = @("None")
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
