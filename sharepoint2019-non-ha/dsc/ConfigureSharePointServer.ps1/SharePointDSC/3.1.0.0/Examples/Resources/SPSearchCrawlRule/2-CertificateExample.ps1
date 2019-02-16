<#
.EXAMPLE
    This example shows how to set a certificate for authentication to a content source
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
            SPSearchCrawlRule IntranetCrawlAccountCertificate
            {
                Path = "https://intranet.sharepoint.contoso.com"
                ServiceAppName = "Search Service Application"
                Ensure = "Present"
                RuleType = "InclusionRule"
                CrawlConfigurationRules = "FollowLinksNoPageCrawl","CrawlComplexUrls", "CrawlAsHTTP"
                AuthenticationType = "CertificateRuleAccess"
                CertificateName = "Certificate Name"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
