<#
.EXAMPLE
    This example only runs the Configuration Wizard in the specified window:
    - Saturday and Sunday night between 3am and 5am.
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
            SPConfigWizard RunConfigWizard
            {
                IsSingleInstance     = "Yes"
                DatabaseUpgradeDays  = "sat", "sun"
                DatabaseUpgradeTime  = "3:00am to 5:00am"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
