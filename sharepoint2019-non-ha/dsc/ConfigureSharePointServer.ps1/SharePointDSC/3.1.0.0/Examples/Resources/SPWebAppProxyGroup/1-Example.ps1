<#
.EXAMPLE
    This example shows how to assign a specific proxy group to the specified web app 
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
            SPWebAppProxyGroup ContosoWeb
            {
                WebAppUrl            = "https://web.contoso.com"
                ServiceAppProxyGroup = "Proxy Group 1"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
