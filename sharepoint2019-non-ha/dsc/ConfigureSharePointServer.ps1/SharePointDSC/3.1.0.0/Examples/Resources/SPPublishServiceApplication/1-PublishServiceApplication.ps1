<#
.EXAMPLE
    This example shows how to ensure that the managed metadata service is published
    within the farm. 
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
            SPPublishServiceApplication PublishManagedMetadataServiceApp
            {
                Name           = "Managed Metadata Service Application"
                Ensure         = "Present"
                InstallAccount = $SetupAccount
            }
        }
    }
