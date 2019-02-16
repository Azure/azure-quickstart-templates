<#
.EXAMPLE
    This example shows how to ensure that specific file types are always blocked while
    others will always be allowed. Any file types not mentioned in this config will be
    able to be managed manually.
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
                EnsureBlocked          = @("exe", "dll", "msi")
                EnsureAllowed          = @("pdf", "docx", "xlsx")
                PsDscRunAsCredential   = $SetupAccount
            }
        }
    }
