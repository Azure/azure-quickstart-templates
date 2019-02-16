<#
.EXAMPLE
    This example shows how to ensure that the blocked file type list always
    specifically matches this list.
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
            SPWebAppBlockedFileTypes PrimaryWebAppBlockedFileTypes
            {
                WebAppUrl              = "http://exmaple.contoso.local"
                Blocked                = @("exe", "dll", "msi")
                PsDscRunAsCredential   = $SetupAccount
            }
        }
    }
