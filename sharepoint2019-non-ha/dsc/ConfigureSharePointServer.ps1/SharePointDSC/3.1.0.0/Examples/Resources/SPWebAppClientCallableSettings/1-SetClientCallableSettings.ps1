<#
.EXAMPLE
    This example shows how to set the client callable settings for a web application
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
            SPWebAppClientCallableSettings DefaultClientCallableSettings
            {
                WebAppUrl                          = "http://example.contoso.local"
                MaxResourcesPerRequest             = 16
                MaxObjectPaths                     = 256
                ExecutionTimeout                   = 90
                RequestXmlMaxDepth                 = 32
                EnableXsdValidation                = $true
                EnableStackTrace                   = $false
                RequestUsageExecutionTimeThreshold = 800
                EnableRequestUsage                 = $true
                LogActionsIfHasRequestException    = $true
                PsDscRunAsCredential               = $SetupAccount
            }
        }
    }
