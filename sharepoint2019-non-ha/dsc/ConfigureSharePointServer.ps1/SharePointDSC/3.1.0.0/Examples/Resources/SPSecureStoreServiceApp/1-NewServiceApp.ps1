<#
.EXAMPLE
    This example creates a new secure store service app.
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
            SPSecureStoreServiceApp SecureStoreServiceApp
            {
                Name            = "Secure Store Service Application"
                ApplicationPool = "SharePoint Service Applications"
                AuditingEnabled = $true
                AuditlogMaxSize = 30
                DatabaseName    = "SP_SecureStore"
                InstallAccount  = $SetupAccount
            }
        }
    }
