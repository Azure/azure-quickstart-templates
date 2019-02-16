<#
.EXAMPLE
    This example sets the super use and reader accounts for the specified web app. It will
    not set the web app policies for these accounts though, allowing them to be controlled
    elsewhere (either manually or with SPWebAppPolicy)
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
                SetWebAppPolicy      = $false
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
