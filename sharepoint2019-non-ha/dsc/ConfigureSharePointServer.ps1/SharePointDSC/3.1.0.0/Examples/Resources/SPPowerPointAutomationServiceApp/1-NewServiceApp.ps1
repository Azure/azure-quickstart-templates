<#
.EXAMPLE
    This example makes sure the service application exists and has a specific configuration
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
            SPPowerPointAutomationServiceApp PowerPointAutomation 
            {
                Name = "PowerPoint Automation Service Application" 
                ProxyName = "PowerPoint Automation Service Application Proxy"
                CacheExpirationPeriodInSeconds = 600
                MaximumConversionsPerWorker = 5
                WorkerKeepAliveTimeoutInSeconds = 120
                WorkerProcessCount = 3
                WorkerTimeoutInSeconds = 300
                ApplicationPool = "SharePoint Web Services"
                Ensure = "Present"
                PsDscRunAsCredential = $SetupAccount 
            } 
        }
    }
