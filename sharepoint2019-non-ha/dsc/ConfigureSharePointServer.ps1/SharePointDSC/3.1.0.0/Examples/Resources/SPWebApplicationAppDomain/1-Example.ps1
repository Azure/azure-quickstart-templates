<#
.EXAMPLE
    This example shows how to set the app domain for a specified web application
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
            SPWebApplicationAppDomain Domain
            {
                AppDomain = "contosointranetapps.com"
                WebAppUrl ="http://portal.contoso.com";
                Zone = "Default";
                Port = 80;
                SSL = $false;
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
