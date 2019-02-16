<#
.EXAMPLE
    This example sets the specific web app policy for the specified web app to
    match the provided list below.
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
                WebAppUrl = "http://sharepoint.contoso.com"
                Members = @(
                    MSFT_SPWebPolicyPermissions {
                        Username           = "contoso\user1"
                        PermissionLevel    = "Full Control"
                        ActAsSystemAccount = $true
                    }
                    MSFT_SPWebPolicyPermissions {
                        Username        = "contoso\Group 1"
                        PermissionLevel = "Full Read"
                        IdentityType    = "Claims"
                    }
                )
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
