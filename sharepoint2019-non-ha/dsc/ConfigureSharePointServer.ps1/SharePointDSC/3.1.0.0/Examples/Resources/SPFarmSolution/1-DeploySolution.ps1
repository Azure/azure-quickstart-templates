<#
.EXAMPLE
    This example shows how to deploy a WSP to specific web applications.
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
            SPFarmSolution SampleWsp
            {
                Name                 = "MySolution.wsp"
                LiteralPath          = "C:\src\MySolution.wsp"
                Ensure               = "Present"
                Version              = "1.0.0"
                WebAppUrls           = @("http://collaboration", "http://mysites")
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
