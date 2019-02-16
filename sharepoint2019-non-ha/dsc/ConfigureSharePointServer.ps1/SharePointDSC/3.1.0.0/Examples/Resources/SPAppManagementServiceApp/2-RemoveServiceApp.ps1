<#
.EXAMPLE
    This example shows how to remove a specific app management service application in the 
    local SharePoint farm. The application pool property is still mandatory but it is not
    used so therefore the value is not important. 
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
            SPAppManagementServiceApp AppManagementServiceApp
            {
                Name                 = "App Management Service Application"
                ApplicationPool      = "n/a"
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount        
            }
        }
    }
