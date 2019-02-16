<#
.EXAMPLE
    This example shows how to apply throttling settings to a specific web app
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
            SPWebAppThrottlingSettings PrimaryWebAppThrottlingSettings
            {
                WebAppUrl                = "http://exmaple.contoso.local"
                ListViewThreshold        = 5000
                AllowObjectModelOverride = $false
                HappyHourEnabled         = $true
                HappyHour                = MSFT_SPWebApplicationHappyHour {
                    Hour     = 3
                    Minute   = 0
                    Duration = 1
                }
                PsDscRunAsCredential     = $SetupAccount
            }
        }
    }
