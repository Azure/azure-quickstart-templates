<#
.EXAMPLE
    This example shows how to apply workflow settings to the specific web application
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
            SPWebAppWorkflowSettings PrimaryWebAppWorkflowSettings
            {
                WebAppUrl                                     = "Shttp://exmaple.contoso.local"
                ExternalWorkflowParticipantsEnabled           = $false
                EmailToNoPermissionWorkflowParticipantsEnable = $false
                PsDscRunAsCredential                          = $SetupAccount
            }
        }
    }
