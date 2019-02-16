<#
.EXAMPLE
    This example shows how to apply specific anti-virus configuration to the farm
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
            SPAntivirusSettings AVSettings
            {
                IsSingleInstance      = "Yes"
                ScanOnDownload        = $true
                ScanOnUpload          = $true
                AllowDownloadInfected = $false
                AttemptToClean        = $false
            }
        }
    }
