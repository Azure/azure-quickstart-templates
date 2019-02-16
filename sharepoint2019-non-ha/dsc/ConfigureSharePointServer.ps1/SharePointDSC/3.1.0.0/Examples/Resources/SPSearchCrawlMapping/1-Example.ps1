<#
.EXAMPLE
    This example shows how to apply a Search Crawl Mapping rule to a search application.
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
            
            SPSearchCrawlMapping IntranetCrawlMapping 
            {
                ServiceAppName = "Search Service Application"
                Url = "http://crawl.sharepoint.com"
                Target = "http://site.sharepoint.com"
                Ensure = "Present"
                PsDScRunAsCredential = $SetupAccount
            }
           
        }
    }


