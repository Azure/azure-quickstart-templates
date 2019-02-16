<#
.EXAMPLE
    This example shows how to create a new project server services service app
    in the local farm
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
                ApplicationPool = "SharePoint Web Services"
                InstallAccount  = $SetupAccount
            }
        }
    }
