<#
.EXAMPLE
    This example takes existing SharePoint databases, based on the database name pattern, and puts
    them in to the specified AlwaysOn Availability Group (AAG).
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
                DatabaseName         = "*Content*"
                AGName               = "MyAvailabilityGroup"
                FileShare            = "\\SQL\Backups"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
