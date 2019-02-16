<#
.EXAMPLE
    This example shows how to disable a health analyzer rule 
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
            SPHealthAnalyzerRuleState DisableDiskSpaceRule
            {
                Name = "Drives are at risk of running out of free space."
                Enabled = $false
                RuleScope   = "All Servers"
                Schedule = "Daily"
                FixAutomatically = $false
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
