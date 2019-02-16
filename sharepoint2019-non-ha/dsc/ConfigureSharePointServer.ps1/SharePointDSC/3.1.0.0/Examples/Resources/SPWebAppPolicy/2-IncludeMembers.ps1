<#
.EXAMPLE
    This example shows how to include specific members while excluding other members
    from the policy of the web app. 
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
            SPWebAppPolicy WebAppPolicy
            {
                WebAppUrl            = "http://sharepoint.contoso.com"
                MembersToInclude = @(
                    @(MSFT_SPWebPolicyPermissions {
                        Username        = "contoso\user1"
                        PermissionLevel = "Full Control"
                    })
                    @(MSFT_SPWebPolicyPermissions {
                        Username        = "contoso\user2"
                        PermissionLevel = "Full Read"
                    })
                )
                MembersToExclude = @(
                    @(MSFT_SPWebPolicyPermissions {
                        Username = "contoso\user3"
                    })
                )
                SetCacheAccountsPolicy = $true 
                PsDscRunAsCredential   = $SetupAccount
            }
        }
    }
