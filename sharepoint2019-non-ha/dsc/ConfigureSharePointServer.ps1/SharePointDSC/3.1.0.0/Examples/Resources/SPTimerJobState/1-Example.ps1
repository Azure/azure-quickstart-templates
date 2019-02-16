<#
.EXAMPLE
    This example show how to disable the dead site delete job in the local farm.
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
            SPTimerJobState DisableTimerJob_AppServerJob
            {
                TypeName             = "Microsoft.Office.Server.Administration.ApplicationServerJob"
                WebAppUrl            = "http://sites.sharepoint.contoso.com"
                Enabled              = $false
                Schedule             ="weekly at sat 5:00"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
