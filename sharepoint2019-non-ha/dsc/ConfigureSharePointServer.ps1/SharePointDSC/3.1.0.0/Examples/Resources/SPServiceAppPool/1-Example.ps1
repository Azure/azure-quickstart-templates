<#
.EXAMPLE
    This example creates a service application pool for service apps to run in.
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
            SPServiceAppPool MainServiceAppPool
            {
                Name                 = "SharePoint Service Applications"
                ServiceAccount       = "Demo\ServiceAccount"
                PsDscRunAsCredential = $SetupAccount
                Ensure               = "Present"
            }
        }
    }
