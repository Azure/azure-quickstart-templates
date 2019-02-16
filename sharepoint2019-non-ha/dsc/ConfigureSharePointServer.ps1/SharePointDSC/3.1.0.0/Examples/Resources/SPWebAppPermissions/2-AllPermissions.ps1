<#
.EXAMPLE
    This example shows how to ensure all permissions are available for a web app
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
            SPWebAppPermissions WebApplicationPermissions
            {
                WebAppUrl            = "https://portal.sharepoint.contoso.com"
                AllPermissions       = $true
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
