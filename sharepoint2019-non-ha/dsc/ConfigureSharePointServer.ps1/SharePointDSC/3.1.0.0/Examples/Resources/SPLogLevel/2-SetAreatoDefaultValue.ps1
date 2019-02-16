<#
.EXAMPLE
    This example sets an entire Area to the default values
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
        SPLogLevel SetAllSPServerToDefault
        {
            Name = "SPServer_defaults"
            SPLogLevelSetting = @(
                MSFT_SPLogLevelItem {
                    Area           = "SharePoint Server"
                    Name           = "*"
                    TraceLevel     = "Default"
                    EventLevel     = "Default"
                }
            )
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
