<#
.EXAMPLE
    This example removes a database from the specified AlwaysOn Availability Group (AAG)
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
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
