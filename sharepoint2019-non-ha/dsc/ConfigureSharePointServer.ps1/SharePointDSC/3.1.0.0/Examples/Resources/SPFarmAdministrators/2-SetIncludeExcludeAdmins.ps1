<#
.EXAMPLE
    This example shows how certain changes are made to the farm admins groups. Here any
    members in the MembersToInclude property are added, and members in the MembersToExclude
    property are removed. Any members that exist in the farm admins group that aren't listed
    in either of these properties are left alone.
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
            SPFarmAdministrators LocalFarmAdmins
            {
                IsSingleInstance     = "Yes"
                MembersToInclude     = @("CONTOSO\user1")
                MembersToExclude     = @("CONTOSO\user2")
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
