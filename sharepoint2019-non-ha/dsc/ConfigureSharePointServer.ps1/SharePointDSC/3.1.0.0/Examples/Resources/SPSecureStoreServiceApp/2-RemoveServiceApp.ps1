<#
.EXAMPLE
    This example removes a secure store service app. The ApplicationPool and
    AuditingEnabled parameters are required, but are not used so their values
    are able to be set to anything.
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
                ApplicationPool = "n/a"
                AuditingEnabled = $false
                InstallAccount  = $SetupAccount
                Ensure          = "Absent"
            }
        }
    }
