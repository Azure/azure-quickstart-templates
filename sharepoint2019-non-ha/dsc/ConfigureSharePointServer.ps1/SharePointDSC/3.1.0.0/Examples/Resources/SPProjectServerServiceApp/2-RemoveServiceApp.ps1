<#
.EXAMPLE
    This example shows how to remove a project server service app in the local farm.
    The ApplicationPool property is still required but is not used when removing, so
    the value used here doesn't matter.
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
            SPProjectServerServiceApp ProjectServiceApp
            {
                Name = "Project Server Service Application"
                ApplicationPool = "n/a"
                Ensure = "Absent"
                InstallAccount  = $SetupAccount
            }
        }
    }
