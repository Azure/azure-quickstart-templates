<#
.EXAMPLE
    This example runs the Configuration Wizard as soon as it is applied.
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
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
