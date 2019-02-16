<#
.EXAMPLE
    This example creates a site collection with the provided details
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
            SPSite TeamSite
            {
                Url                      = "http://sharepoint.contoso.com"
                OwnerAlias               = "CONTOSO\ExampleUser"
                HostHeaderWebApplication = "http://spsites.contoso.com"
                Name                     = "Team Sites"
                Template                 = "STS#0"
                PsDscRunAsCredential     = $SetupAccount
            }
        }
    }
