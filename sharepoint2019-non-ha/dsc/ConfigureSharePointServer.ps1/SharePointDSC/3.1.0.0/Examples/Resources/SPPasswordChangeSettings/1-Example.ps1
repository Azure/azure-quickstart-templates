<#
.EXAMPLE
    This example sets the password change settings for managed accounts in the local farm
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
            SPPasswordChangeSettings ManagedAccountPasswordResetSettings
            {
                IsSingleInstance              = "Yes"
                MailAddress                   = "sharepoint@contoso.com"
                DaysBeforeExpiry              = "14"
                PasswordChangeWaitTimeSeconds = "60"
                NumberOfRetries               = "3"
                PsDscRunAsCredential          = $SetupAccount
            }
        }
    }
