<#
.EXAMPLE
    This example shows how to apply some of the available general settings to the
    specified web app
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
            SPWebAppGeneralSettings PrimaryWebAppGeneralSettings
            {
                WebAppUrl              = "http://exmaple.contoso.local"
                TimeZone               = 76
                Alerts                 = $true
                RSS                    = $false
                PsDscRunAsCredential   = $SetupAccount
            }
        }
    }
