<#
.EXAMPLE
    This example applies the distributed cache service to the current server,
    but will not apply the rules to allow it to communicate with other cache 
    hosts to the Windows Firewall. Use this approach if you have an alternate
    firewall solution.
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
            SPDistributedCacheService EnableDistributedCache
            {
                Name                 = "AppFabricCachingService"
                CacheSizeInMB        = 8192
                ServiceAccount       = "DEMO\ServiceAccount"
                InstallAccount       = $SetupAccount
                CreateFirewallRules  = $false
            }
        }
    }
