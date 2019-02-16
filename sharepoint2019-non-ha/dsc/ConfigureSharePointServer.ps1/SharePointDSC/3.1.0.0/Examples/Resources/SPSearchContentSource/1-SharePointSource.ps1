<#
.EXAMPLE
    This example shows how to create a SharePoint sites content source
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
            SPSearchContentSource LocalSharePointSites
            {
                Name                 = "Local SharePoint Sites"
                ServiceAppName       = "Search Service Application"
                ContentSourceType    = "SharePoint"
                Addresses            = @("http://sharepointsite1.contoso.com", "http://sharepointsite2.contoso.com")
                CrawlSetting         = "CrawlEverything"
                ContinuousCrawl      = $true
                FullSchedule         = $null
                Priority             = "Normal"
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
