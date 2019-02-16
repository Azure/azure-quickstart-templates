<#
.EXAMPLE
    This example shows how to apply the RMS settings to a local farm, pointing to
    a specific RMS server
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
            SPIrmSettings RMSSettings
            {
                IsSingleInstance     = "Yes"
                RMSserver            = "https://rms.contoso.com"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
