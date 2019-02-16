<#
.EXAMPLE
    This example removes a word automation service app
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
            SPWordAutomationServiceApp WordAutomation 
            {
                Name = "Word Automation Service Application" 
                Ensure = "Absent"
                PsDscRunAsCredential = $SetupAccount 
            }
        }
    }
