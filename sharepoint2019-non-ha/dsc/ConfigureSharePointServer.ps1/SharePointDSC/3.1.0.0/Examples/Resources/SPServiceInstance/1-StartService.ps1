<#
.EXAMPLE
    This example shows how to ensure that the managed metadata service is running
    on the local server. 
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
            SPServiceInstance ManagedMetadataServiceInstance
            {
                Name           = "Managed Metadata Web Service"
                Ensure         = "Present"
                InstallAccount = $SetupAccount
            }
        }
    }
