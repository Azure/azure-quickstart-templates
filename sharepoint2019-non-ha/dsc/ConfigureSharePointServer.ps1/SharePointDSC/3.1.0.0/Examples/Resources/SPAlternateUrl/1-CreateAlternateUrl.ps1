<#
.EXAMPLE
    This example shows how to add a new alternate URL to a specific web application
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
            SPAlternateUrl CentralAdminAAM
            {
                WebAppName           = "SharePoint - www.domain.com80"
                Zone                 = "Intranet"
                Url                  = "https://admin.sharepoint.contoso.com"
                Internal             = $false
                Ensure               = "Present"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
