<#
.EXAMPLE
    This example sets an Area / Category item to a custom value.
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
        SPLogLevel SetUserProfileLogingtoVerbose
        {
            Name = "SP_Database-Verbose"
            SPLogLevelSetting = @(
                MSFT_SPLogLevelItem {
                    Area           = "SharePoint Server"
                    Name           = "Database"
                    TraceLevel     = "Verbose"
                    EventLevel     = "Verbose"
                }
            )
            PsDscRunAsCredential = $SetupAccount
        }
    }
}
