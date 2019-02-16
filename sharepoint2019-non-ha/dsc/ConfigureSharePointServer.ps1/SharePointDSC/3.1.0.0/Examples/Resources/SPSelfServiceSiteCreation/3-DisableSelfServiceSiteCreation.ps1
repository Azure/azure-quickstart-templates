<#
.EXAMPLE
    This example shows how to disable self-service site creation for a web application
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
            SPSelfServiceSiteCreation SSC
            {
                WebAppUrl               = "http://example.contoso.local"
                Enabled                 = $false
                PsDscRunAsCredential    = $SetupAccount
            }
        }
    }
