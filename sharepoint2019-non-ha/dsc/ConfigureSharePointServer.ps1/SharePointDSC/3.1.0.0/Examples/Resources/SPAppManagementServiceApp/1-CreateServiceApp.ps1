<#
.EXAMPLE
    This example shows how to create a new app management service application in the 
    local SharePoint farm.
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
                ApplicationPool      = "SharePoint Service Applications"
                DatabaseServer       = "SQL01.contoso.com"
                DatabaseName         = "SP_AppManagement"
                PsDscRunAsCredential = $SetupAccount        
            }
        }
    }
