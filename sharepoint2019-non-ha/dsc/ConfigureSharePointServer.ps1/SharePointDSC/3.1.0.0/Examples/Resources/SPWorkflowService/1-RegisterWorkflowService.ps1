<#
.EXAMPLE
    This example registers the workflow service over http.
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
            SPWorkflowService WorkflowService
            {
                WorkflowHostUri      = "http://workflow.sharepoint.contoso.com"
                SPSiteUrl            = "http://sites.sharepoint.com"
                AllowOAuthHttp       = $true
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
