<#
.EXAMPLE
    This example shows how to create a new visio services service app in the local farm
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
                ApplicationPool = "SharePoint Web Services"
                InstallAccount  = $SetupAccount
            }
        }
    }
