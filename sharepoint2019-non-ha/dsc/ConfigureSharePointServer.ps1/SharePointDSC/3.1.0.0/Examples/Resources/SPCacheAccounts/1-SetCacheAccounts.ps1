<#
.EXAMPLE
    This example sets the super use and reader accounts for the specified web app. It will
    also set the appropriate web app policies by default for these accounts.
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
            SPCacheAccounts SetCacheAccounts
            {
                WebAppUrl            = "http://sharepoint.contoso.com"
                SuperUserAlias       = "DEMO\svcSPSuperUser"
                SuperReaderAlias     = "DEMO\svcSPReader"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
