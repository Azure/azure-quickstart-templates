<#
.EXAMPLE
    This example applies the distributed cache service to the current server,
    also setting the rules in Windows firewall to allow communication with
    other cache hosts.
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
                CreateFirewallRules  = $true
            }
        }
    }
