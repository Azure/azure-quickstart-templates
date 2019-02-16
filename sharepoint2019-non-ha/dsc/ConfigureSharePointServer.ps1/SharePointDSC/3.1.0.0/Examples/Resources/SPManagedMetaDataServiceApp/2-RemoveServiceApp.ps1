<#
.EXAMPLE

    This example shows how to remove a specific managed metadata service app from the 
    local SharePoint farm. Because Application pool parameter is required
    but is not acutally needed to remove the app, any text value can 
    be supplied for these as it will be ignored. 
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
                ApplicationPool   = "none"
                Ensure            = "Absent"
            }
        }
    }
