<#
.EXAMPLE
    This example dismounts a content database from the specified web application. This 
    will not remove the database from SQL server however, only taking it out of the 
    web applications configuration.
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
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
