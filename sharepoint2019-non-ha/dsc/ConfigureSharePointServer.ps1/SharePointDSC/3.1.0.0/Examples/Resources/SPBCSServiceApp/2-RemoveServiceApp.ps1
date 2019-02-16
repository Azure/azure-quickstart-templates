<#
.EXAMPLE
    This example shows how to deploy a Business Connectivity Services application to the
    local SharePoint farm. The application pool account is mandatory but the value is 
    ignored when removing a service app, so the value entered here does not matter. 
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
            SPBCSServiceApp BCSServiceApp
            {
                Name                 = "BCS Service Application"
                ApplicationPool      = "n/a"
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
