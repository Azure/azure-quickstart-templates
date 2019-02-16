<#
.EXAMPLE
    This example shows how to enable tenant administration for a web application in a SharePoint 2013 farm
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
            $proxyLibraries = @()
            $proxyLibraries += MSFT_SPProxyLibraryEntry {
                AssemblyName = "Microsoft.Online.SharePoint.Dedicated.TenantAdmin.ServerStub, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c"
                SupportAppAuthentication = $true
            }

            SPWebAppClientCallableSettings TenantAdministration
            {
                WebAppUrl            = "http://example.contoso.local"
                ProxyLibraries       = $proxyLibraries
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
