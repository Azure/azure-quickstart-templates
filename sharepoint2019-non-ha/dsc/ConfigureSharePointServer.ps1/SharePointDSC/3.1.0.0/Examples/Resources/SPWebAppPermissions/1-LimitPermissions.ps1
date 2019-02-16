<#
.EXAMPLE
    This example shows how to limit the available permisions within a web app
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
            SPWebAppPermissions WebApplicationPermissions
            {
                WebAppUrl = "https://intranet.sharepoint.contoso.com"
                ListPermissions     = "Manage Lists","Override List Behaviors","Add Items","Edit Items","Delete Items","View Items","Approve Items","Open Items","View Versions","Delete Versions","Create Alerts","View Application Pages"
                SitePermissions     = "Manage Permissions","View Web Analytics Data","Create Subsites","Manage Web Site","Add and Customize Pages","Apply Themes and Borders","Apply Style Sheets","Create Groups","Browse Directories","Use Self-Service Site Creation","View Pages","Enumerate Permissions","Browse User Information","Manage Alerts","Use Remote Interfaces","Use Client Integration Features","Open","Edit Personal User Information"
                PersonalPermissions = "Manage Personal Views","Add/Remove Personal Web Parts","Update Personal Web Parts"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
