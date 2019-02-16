<#
.EXAMPLE
    This example shows how to ensure the farm is always compliant with MinRole settings
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
            SPMinRoleCompliance MinRoleCompliance
            {
                IsSingleInstance     = "Yes"
                State                = "Compliant"
                PSDscRunAsCredential = $SetupAccount
            }
        }
    }
