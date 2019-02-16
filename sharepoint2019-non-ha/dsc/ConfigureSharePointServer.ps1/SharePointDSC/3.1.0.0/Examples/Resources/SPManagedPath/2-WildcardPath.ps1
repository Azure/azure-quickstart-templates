<#
.EXAMPLE
    This example shows how to add a wildcard managed path to a specific web application
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
            SPManagedPath TestManagedPath 
            {
                WebAppUrl      = "http://sharepoint.contoso.com"
                InstallAccount = $SetupAccount
                RelativeUrl    = "teams"
                Explicit       = $false
                HostHeader     = $true
            }
        }
    }
