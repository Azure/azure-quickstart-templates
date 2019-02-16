<#
.EXAMPLE
    This example shows how to deploy Access Services 2013 to the local SharePoint farm.
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
            SPAccessServiceApp AccessServices
            {
                Name                 = "Access Services Service Application"
                ApplicationPool      = "SharePoint Service Applications" 
                DatabaseServer       = "SQL.contoso.local\SQLINSTANCE"
                PsDscRunAsCredential = $SetupAccount
            }
        }
    }
