<#
.EXAMPLE
    This example shows how to remove a visio services service app in the local farm.
    The ApplicationPool property is still requried but is not used when removing, so
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
            SPVisioServiceApp VisioServices
            {
                Name = "Visio Graphics Service Application"
                ApplicationPool = "n/a"
                Ensure = "Absent"
                InstallAccount  = $SetupAccount
            }
        }
    }
