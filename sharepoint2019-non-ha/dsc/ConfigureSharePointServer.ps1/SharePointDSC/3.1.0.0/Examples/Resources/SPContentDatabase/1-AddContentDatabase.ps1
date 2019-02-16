<#
.EXAMPLE
    This example creates a new content database for the specified web application.
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
            SPContentDatabase ContentDB 
            {
                Name                 = "SharePoint_Content_01"
                DatabaseServer       = "SQL.contoso.local\SQLINSTANCE"
                WebAppUrl            = "http://sharepoint.contoso.com"
                Enabled              = $true
                WarningSiteCount     = 2000
                MaximumSiteCount     = 5000
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
