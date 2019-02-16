<#
.EXAMPLE
    This example configures the site collection urls for the specified
    Host Named Site Collection
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
            SPSiteUrl TeamSite
            {
                Url                  = "http://sharepoint.contoso.intra"
                Intranet             = "http://sharepoint.contoso.com"
                Internet             = "https://sharepoint.contoso.com"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
