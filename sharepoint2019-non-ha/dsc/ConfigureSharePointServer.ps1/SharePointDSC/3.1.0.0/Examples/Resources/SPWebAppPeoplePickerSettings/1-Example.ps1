<#
.EXAMPLE
    This example shows how to configure the people picker settings on the specified web application
#>

    Configuration Example
    {
        param(
            [Parameter(Mandatory = $true)]
            [PSCredential]
            $AccessAccount,

            [Parameter(Mandatory = $true)]
            [PSCredential]
            $SetupAccount
        )
        Import-DscResource -ModuleName SharePointDsc

        node localhost {
            SPWebAppPeoplePickerSettings ConfigurePeoplePicker
            {
                WebAppUrl                      = "http://sharepoint.contoso.com"
                ActiveDirectoryCustomFilter    = $null
                ActiveDirectoryCustomQuery     = $null
                ActiveDirectorySearchTimeout   = 30
                OnlySearchWithinSiteCollection = $false
                SearchActiveDirectoryDomains   = @(
                    MSFT_SPWebAppPPSearchDomain {
                        FQDN          = "contoso.com"
                        IsForest      = $false
                        AccessAccount = $AccessAccount
                    }
                )
                PsDscRunAsCredential           = $SetupAccount
            }
        }
    }
