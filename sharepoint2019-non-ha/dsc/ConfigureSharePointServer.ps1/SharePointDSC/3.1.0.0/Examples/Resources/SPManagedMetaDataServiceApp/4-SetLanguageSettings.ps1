<#
.EXAMPLE
    This example shows how to deploy the Managed Metadata service app to the local SharePoint farm
    and also include a specific list of users to be the term store administrators.
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
                Name                    = "Managed Metadata Service Application"
                ApplicationPool         = "SharePoint Service Applications"
                DatabaseServer          = "SQL.contoso.local"
                DatabaseName            = "SP_ManagedMetadata"
                TermStoreAdministrators = @(
                    "CONTOSO\user1",
                    "CONTOSO\user2"
                )
                DefaultLanguage      = 1033
                Languages            = @(1031, 1033)
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
