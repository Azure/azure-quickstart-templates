<#
.EXAMPLE
    This example gives admin access to the specified users for the local farm as
    well as all content databases in the local farm, with the exception of database
    WSS_Content_Portal.
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
            SPShellAdmins ShellAdmins
            {
                IsSingleInstance = "Yes"
                Members          = "CONTOSO\user1", "CONTOSO\user2"
                AllDatabases     = $true
                ExcludeDatabases = "WSS_Content_Portal"
            }
        }
    }
