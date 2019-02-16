<#
.EXAMPLE
    This example shows how to apply settings to a sepcific URL in search
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
            SPSearchCrawlRule IntranetCrawlAccount
            {
                Path = "https://intranet.sharepoint.contoso.com"
                ServiceAppName = "Search Service Application"
                Ensure = "Present"
                RuleType = "InclusionRule"
                CrawlConfigurationRules = "FollowLinksNoPageCrawl","CrawlComplexUrls", "CrawlAsHTTP"
                AuthenticationType = "DefaultRuleAccess"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
