<#
.EXAMPLE
    This example creates two seperate proxy groups of service apps that can be 
    assigned to web apps in the farm
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
            SPServiceAppProxyGroup ProxyGroup1
            {
                Name                = "Proxy Group 1"
                Ensure              = "Present"
                ServiceAppProxies   = "Web 1 User Profile Service Application","Web 1 MMS Service Application","State Service Application"
            }

            SPServiceAppProxyGroup ProxyGroup2
            {
                Name                = "Proxy Group 2"
                Ensure              = "Present"
                ServiceAppProxiesToInclude = "Web 2 User Profile Service Application"
            }
        }
    }
