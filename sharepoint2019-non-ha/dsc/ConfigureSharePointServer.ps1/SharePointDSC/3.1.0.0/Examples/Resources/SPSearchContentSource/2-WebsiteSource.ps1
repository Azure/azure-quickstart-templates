<#
.EXAMPLE
    This example shows how to create a website content source
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
            SPSearchContentSource WebsiteSource
            {
                Name                 = "Contoso website"
                ServiceAppName       = "Search Service Application"
                ContentSourceType    = "Website"
                Addresses            = @("http://www.contoso.com")
                CrawlSetting         = "Custom"
                LimitPageDepth       = 5
                IncrementalSchedule  = MSFT_SPSearchCrawlSchedule{
                                        ScheduleType = "Daily"
                                        StartHour = "0"
                                        StartMinute = "0"
                                        CrawlScheduleRepeatDuration = "1440"
                                        CrawlScheduleRepeatInterval = "5"
                                       }
                FullSchedule         = MSFT_SPSearchCrawlSchedule{
                                        ScheduleType = "Weekly"
                                        CrawlScheduleDaysOfWeek = @("Monday", "Wednesday", "Friday")
                                        StartHour = "3"
                                        StartMinute = "0"
                                       }
                Priority             = "Normal"
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
