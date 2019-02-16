<#
.EXAMPLE
    This example creates a remote farm trust so that the local web app trusts calls 
    that will come from the remote web app. 
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
            SPRemoteFarmTrust TrustRemoteFarmForSearch
            {
                Name = "CentralSearchFarm"
                RemoteWebAppUrl = "https://search.sharepoint.contoso.com"
                LocalWebAppUrl = "https://local.sharepoint2.contoso.com"
            }
        }
    }
