<#
.EXAMPLE
    This example demonstrates how to apply timesheet settings to a specific
    PWA instance
#>

Configuration Example 
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $SetupAccount
    )
    Import-DscResource -ModuleName SharePointDsc

    node localhost 
    {
        SPProjectServerTimeSheetSettings ConfigureTimeSheets
        {
            Url                      = "http://projects.contoso.com/pwa"
            HoursInStandardDay       = 8
            HoursInStandardWeek      = 40
            AllowFutureTimeReporting = $false  
            PsDscRunAsCredential     = $SetupAccount
        }
    }
}
