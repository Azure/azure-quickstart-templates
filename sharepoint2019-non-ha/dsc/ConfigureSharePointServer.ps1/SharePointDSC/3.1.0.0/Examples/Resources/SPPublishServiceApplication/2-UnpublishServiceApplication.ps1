<#
.EXAMPLE
    This example shows how to ensure that the Secure Store Service is not 
    published within the farm. 
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
            SPPublishServiceApplication UnpublishSecureStoreServiceApp
            {
                Name           = "Secure Store Service Application"
                Ensure         = "Absent"
                InstallAccount = $SetupAccount
            }
        }
    }
