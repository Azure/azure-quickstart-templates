<#
.EXAMPLE
    This example takes an existing SharePoint database and puts it in to the specified
    AlwaysOn Availability Group (AAG).
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
            SPDatabaseAAG ConfigDBAAG
            {
                DatabaseName         = "SP_Config"
                AGName               = "MyAvailabilityGroup"
                FileShare            = "\\SQL\Backups"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
