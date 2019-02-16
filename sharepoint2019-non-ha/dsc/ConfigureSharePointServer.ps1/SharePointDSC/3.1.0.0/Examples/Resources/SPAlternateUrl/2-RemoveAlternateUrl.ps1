<#
.EXAMPLE
    This example shows how to remove an alternate URL from a specified zone for a specific
    web application.
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
                Url                  = "http://www.externaldomain.com"
                Internal             = $false
                Ensure               = "Absent"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
