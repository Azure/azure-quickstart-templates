<#
.EXAMPLE
    This example deploys a subsite in a specific location
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
            SPWeb TeamSite
            {
                Url                      = "http://sharepoint.contoso.com/sites/site/subweb"
                Name                     = "Team Sites"
                Ensure                   = "Present"
                Description              = "A place to share documents with your team."
                Template                 = "STS#0"
                Language                 = 1033
                AddToTopNav              = $true
                PsDscRunAsCredential     = $SetupAccount
            }
        }
    }
