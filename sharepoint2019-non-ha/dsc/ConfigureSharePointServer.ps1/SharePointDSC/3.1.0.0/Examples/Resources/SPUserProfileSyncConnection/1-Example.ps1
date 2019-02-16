<#
.EXAMPLE
    This example adds a new user profile sync connection to the specified user 
    profile service app
#>

    Configuration Example 
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $ConnectionAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPUserProfileSyncConnection MainDomain
            {
                UserProfileService = "User Profile Service Application"
                Forest = "contoso.com"
                Name = "Contoso"
                ConnectionCredentials = $ConnectionAccount
                Server = "server.contoso.com"
                UseSSL = $false
                IncludedOUs = @("OU=SharePoint Users,DC=Contoso,DC=com")
                ExcludedOUs = @("OU=Notes Usersa,DC=Contoso,DC=com")
                Force = $false
                ConnectionType = "ActiveDirectory"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
