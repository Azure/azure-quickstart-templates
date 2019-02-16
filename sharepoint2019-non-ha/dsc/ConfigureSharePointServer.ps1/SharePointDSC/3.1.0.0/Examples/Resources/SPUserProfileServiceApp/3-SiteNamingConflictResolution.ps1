<#
.EXAMPLE
    This example adds a new user profile service application to the local farm
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
            SPUserProfileServiceApp UserProfileServiceApp
            {
                Name                         = "User Profile Service Application"
                ApplicationPool              = "SharePoint Service Applications"
                MySiteHostLocation           = "http://my.sharepoint.contoso.local"
                MySiteManagedPath            = "personal"
                ProfileDBName                = "SP_UserProfiles"
                ProfileDBServer              = "SQL.contoso.local\SQLINSTANCE"
                SocialDBName                 = "SP_Social"
                SocialDBServer               = "SQL.contoso.local\SQLINSTANCE"
                SyncDBName                   = "SP_ProfileSync"
                SyncDBServer                 = "SQL.contoso.local\SQLINSTANCE"
                EnableNetBIOS                = $false
                SiteNamingConflictResolution = "Domain_Username"
                PsDscRunAsCredential         = $SetupAccount
            }
        }
    }
