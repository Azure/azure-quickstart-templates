<#
.EXAMPLE
    This example sets multiple items to custom values
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
        SPLogLevel SetCustomValues
        {
            Name = "CustomLoggingSettings"
            SPLogLevelSetting = @(
                MSFT_SPLogLevelItem {
                    Area           = "SharePoint Server"
                    Name           = "Database"
                    TraceLevel     = "Verbose"
                    EventLevel     = "Verbose"
                }
                MSFT_SPLogLevelItem {
                    Area = "Business Connectivity Services"
                    Name = "Business Data"
                    TraceLevel     = "Unexpected"
                    EventLevel     = "Error"
                }
            )
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
