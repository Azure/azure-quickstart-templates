<#
.EXAMPLE
    This example shows how to deploy a Business Connectivity Services application to the
    local SharePoint farm. 
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
            SPBCSServiceApp BCSServiceApp
            {
                Name            = "BCS Service Application"
                ApplicationPool = "SharePoint Service Applications"
                DatabaseName    = "SP_BCS"
                DatabaseServer  = "SQL.contoso.local\SQLINSTANCE"
                InstallAccount  = $SetupAccount
            }
        }
    }
