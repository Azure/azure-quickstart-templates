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
            SPPowerPointAutomationServiceApp WordAutomation 
            {
                Name = "PowerPoint Automation Service Application" 
                Ensure = "Absent"
                PsDscRunAsCredential = $SetupAccount 
            }
        }
    }
