<#
.EXAMPLE
    This example shows how to deploy an explicit managed path to a specifici web application
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
                RelativeUrl    = "example"
                Explicit       = $true
                HostHeader     = $false
            }
        }
    }
