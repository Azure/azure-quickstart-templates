<#
.EXAMPLE
    This example shows how to deploy the Managed Metadata service app to the local SharePoint farm.
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
            SPManagedMetaDataServiceApp ManagedMetadataServiceApp
            {
                Name              = "Managed Metadata Service Application"
                InstallAccount    = $SetupAccount
                ApplicationPool   = "SharePoint Service Applications"
                DatabaseServer    = "SQL.contoso.local"
                DatabaseName      = "SP_ManagedMetadata"
            }
        }
    }
