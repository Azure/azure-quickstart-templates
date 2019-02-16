<#
.EXAMPLE
    This example shows how to create a new Search Metadata Category, using the required parameters
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
            SPSearchMetadataCategory NewCategory
            {
                Name                           = "My New category"
                ServiceAppName                 = "Search Service Application"
                AutoCreateNewManagedProperties = $true
                DiscoverNewProperties          = $true
                MapToContents                  = $true
                Ensure                         = "Present"
                PsDscRunAsCredential           = $SetupAccount
            }
        }
    }
